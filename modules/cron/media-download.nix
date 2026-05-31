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
  options.local.cron.media-download.enable = lib.mkEnableOption "automatic media downloader";

  config = lib.mkIf cfg.enable {
    local.healthchecks-secret.enable = true;
    local.rclone.enable = true;

    sops.secrets.miniflux = {owner = "mawz";};

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
        vidDir = "/zvault/syncthing/media/vids/";
        # TODO: revert unstable
        dlVids =
          pkgs.unstable.writers.writePython3Bin "dl_vids" {
            libraries = with pkgs.unstable.python3Packages; [miniflux yt-dlp];
            makeWrapperArgs = [
              "--prefix"
              "PATH"
              ":"
              "${lib.makeBinPath [pkgs.ffmpeg]}"
            ];
          } ''
            from datetime import datetime, timezone
            import miniflux
            import warnings
            import yt_dlp

            _url = "${mfUrl}"
            _key_path = "${mfKey}"
            _paths = {"home": "${vidDir}"}
            _categories = [26, 5]


            def get_miniflux_client():
                with open(_key_path) as f:
                    api_key = f.read().strip()
                return miniflux.Client(_url, api_key=api_key)


            mf_cli = get_miniflux_client()
            yt_cli = yt_dlp.YoutubeDL(params={"paths": _paths})


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


            def dl_vids(urls):
                yt_cli.download(urls)


            for category in _categories:
                vids = category_entries(category)
                dl_vids(vids)
          '';
      in ''
        ${lib.getExe dlVids}

        ${utils.writeHealthchecksPingScript {slug = "media-download";}}
      '';
    };
  };
}
