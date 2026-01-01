{
  config,
  pkgs,
  lib,
  local,
  ...
}: let
  cfg = config.local.cron.kindle-export;
  utils = local.utils;
in {
  options.local.cron.kindle-export.enable = lib.mkEnableOption "kindle export";

  config = lib.mkIf cfg.enable {
    local.services.postfix.enable = true;

    sops.secrets."readeck/cron-api-key" = {};
    sops.secrets."readeck/kindle-export-receiver" = {};

    systemd.timers.kindle-export = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "weekly";
        Unit = "kindle-export.service";
      };
    };
    systemd.services.kindle-export = {
      script = let
        convert = "${pkgs.calibre}/bin/ebook-convert";
      in ''
        key="$(cat ${config.sops.secrets."readeck/cron-api-key".path})"
        receiver="$(cat ${config.sops.secrets."readeck/kindle-export-receiver".path})"

        tmpdir=$(mktemp -d /tmp/kindle-export-XXXXXX)
        basename=$(date +"%Y-%m-%d")-readeck-bookmarks
        basepath="$tmpdir/$basename"

        ${lib.getExe pkgs.curl} -X GET "${utils.serviceUrl "readeck"}/api/bookmarks/export.epub?author=&is_archived=false&labels=&range_end=&range_start=&search=&site=&title=&sort=-created" -H "accept: application/epub+zip" -H "Authorization: Bearer $key" -o "$basepath-orig.epub"

        ${convert} "$basepath-orig.epub" "$basepath.mobi"
        ${convert} "$basepath.mobi" "$basepath.epub"

        boundary=$(${lib.getExe pkgs.openssl} rand -base64 12)
        (
          echo "From: Readeck <noreply@readeck.lan>"
          echo "To: $receiver"
          echo "Subject: Readeck export"
          echo "Mime-Version: 1.0"
          echo "Content-Type: multipart/mixed; boundary=\"$boundary\""
          echo
          echo "--$boundary"
          echo "Content-Type: application;"
          echo "Content-Transfer-Encoding: base64"
          echo "Content-Disposition: attachment; filename=\"$basename.epub\""
          echo
          echo $(${pkgs.coreutils}/bin/base64 "$basepath.epub")
          echo
          echo "--$boundary--"
        ) | ${pkgs.postfix}/bin/sendmail $receiver

        ${utils.writeHealthchecksPingScript {slug = "kindle-export";}}
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };
}
