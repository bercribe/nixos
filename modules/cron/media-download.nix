{
  pkgs,
  lib,
  config,
  local,
  ...
}: let
  cfg = config.local.cron.media-download;
  utils = local.utils;
in {
  imports = [
    ../../modules/clients/mullvad-proxy
  ];

  options.local.cron.media-download.enable = lib.mkEnableOption "automatic media downloader";

  config = lib.mkIf cfg.enable {
    local.healthchecks-secret.enable = true;
    local.rclone.enable = true;
    local.clients.mullvad-proxy.enable = true;

    sops.secrets.miniflux = {owner = "mawz";};
    sops.secrets.readeck = {owner = "mawz";};

    systemd.timers.media-download = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "1d";
        OnUnitActiveSec = "1d";
        Unit = "media-download.service";
      };
    };
    systemd.services.media-download = {
      serviceConfig = {
        Type = "oneshot";
        User = "mawz";
      };
      script = let
        mfUrl = utils.serviceUrl "miniflux";
        mfKey = config.sops.secrets.miniflux.path;
        rdUrl = utils.serviceUrl "readeck";
        rdKey = config.sops.secrets.readeck.path;
        vidDir = "/zvault/syncthing/media/vids/";

        # TODO: revert unstable
        ytDlpPinned = pkgs.unstable.python3Packages.yt-dlp.overrideAttrs (old: rec {
          version = "2026.08.19";
          src = old.src.override {
            tag = version;
            hash = "sha256-BM5ZeGTmHq+1xH6G/zsuCtjLgYgfRA11ya0zIHK5p4g=";
          };
        });
        dlVids =
          pkgs.unstable.writers.writePython3Bin "dl_vids" {
            libraries = [pkgs.unstable.python3Packages.miniflux ytDlpPinned];
            makeWrapperArgs = [
              "--prefix"
              "PATH"
              ":"
              "${lib.makeBinPath [pkgs.ffmpeg]}"
            ];
          } ''
            from datetime import datetime, timezone
            import miniflux
            import os
            import requests
            import warnings
            import yt_dlp

            print(f"yt-dlp version: {yt_dlp.version.__version__}")

            _url = "${mfUrl}"
            _key_path = "${mfKey}"
            _readeck_url = "${rdUrl}"
            _readeck_key_path = "${rdKey}"
            _paths = {"home": "${vidDir}"}
            _categories = [26, 5]


            def get_miniflux_client():
                with open(_key_path) as f:
                    api_key = f.read().strip()
                return miniflux.Client(_url, api_key=api_key)


            mf_cli = get_miniflux_client()
            yt_cli = yt_dlp.YoutubeDL(params={
                "paths": _paths,
                "proxy": "${config.local.clients.mullvad-proxy.url}",
            })


            def category_entries(id):
                limit = 200
                response = mf_cli.get_category_entries(id, status="unread", limit=limit)
                entries = [e for e in response["entries"]]
                if len(entries) == limit:
                    warnings.warn("hit article limit!")

                urls = []
                for e in entries:
                    published = datetime.strptime(e["published_at"], "%Y-%m-%dT%H:%M:%S%z")
                    now = datetime.now(timezone.utc)
                    delta = now - published
                    delta_days = delta.days
                    if delta_days < 7:
                        continue

                    url = e["url"]
                    urls.append(url)
                return urls


            def get_readeck_vids():
                with open(_readeck_key_path) as f:
                    api_key = f.read().strip()
                resp = requests.get(
                    f"{_readeck_url}/api/bookmarks?is_archived=false",
                    headers={"Authorization": f"Bearer {api_key}"},
                )
                bookmarks = resp.json()
                urls = [b["url"] for b in bookmarks]
                youtube_urls = [u for u in urls if "youtu" in u]
                return youtube_urls


            def dl_vids(urls):
                succeeded = 0
                failed = []
                for url in urls:
                    try:
                        info = yt_cli.extract_info(url, download=False)
                        filename = yt_cli.prepare_filename(info)
                        already_existed = os.path.exists(filename)
                        if already_existed:
                            continue
                        yt_cli.download([url])
                        succeeded += 1
                    except Exception as e:
                        warnings.warn(f"Skipping {url}: {e}")
                        failed.append(url)
                if failed:
                    print(f"Failed to download {len(failed)} video(s):")
                    for url in failed:
                        print(f"  - {url}")
                    if succeeded == 0:
                        raise RuntimeError("no download succeeded!")


            vids = []
            for category in _categories:
                vids.extend(category_entries(category))
            vids.extend(get_readeck_vids())

            dl_vids(vids)
          '';
      in ''
        ${lib.getExe dlVids}

        ${utils.writeHealthchecksPingScript {slug = "media-download";}}
      '';
    };
  };
}
