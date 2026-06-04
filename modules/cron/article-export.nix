{
  config,
  pkgs,
  lib,
  local,
  ...
}: let
  cfg = config.local.cron.article-export;
  utils = local.utils;
in {
  options.local.cron.article-export.enable = lib.mkEnableOption "article export";

  config = lib.mkIf cfg.enable {
    local.services.postfix.enable = true;

    sops.secrets.readeck = {owner = "mawz";};
    sops.secrets.kindle-receiver = {owner = "mawz";};
    sops.secrets.pocketbook-receiver = {owner = "mawz";};

    systemd.timers.article-export = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "weekly";
        Unit = "article-export.service";
      };
    };
    systemd.services.article-export = {
      path = ["/run/wrappers"];
      script = let
        convert = "${pkgs.calibre}/bin/ebook-convert";
        articleDir = "/zvault/syncthing/media/articles/";
      in ''
        key="$(cat ${config.sops.secrets.readeck.path})"
        kindleReceiver="$(cat ${config.sops.secrets.kindle-receiver.path})"
        pocketbookReceiver="$(cat ${config.sops.secrets.pocketbook-receiver.path})"

        tmpdir=$(mktemp -d /tmp/article-export-XXXXXX)
        basename=$(date +"%Y-%m-%d")-readeck-bookmarks
        basepath="$tmpdir/$basename"

        ${lib.getExe pkgs.curl} -X GET "${utils.serviceUrl "readeck"}/api/bookmarks/export.epub?author=&is_archived=false&labels=&range_end=&range_start=&search=&site=&title=&sort=-created" -H "accept: application/epub+zip" -H "Authorization: Bearer $key" -o "$basepath-orig.epub"

        ${convert} "$basepath-orig.epub" "$basepath.mobi"
        ${convert} "$basepath.mobi" "$basepath.epub"

        boundary=$(${lib.getExe pkgs.openssl} rand -base64 12)
        (
          echo "From: Readeck <noreply@readeck.lan>"
          echo "To: $kindleReceiver"
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
        ) | sendmail $kindleReceiver

        boundary=$(${lib.getExe pkgs.openssl} rand -base64 12)
        (
          echo "From: Readeck <noreply@readeck.lan>"
          echo "To: $pocketbookReceiver"
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
        ) | sendmail $pocketbookReceiver

        mkdir -p ${articleDir}
        mv "$basepath.epub" ${articleDir}

        ${utils.writeHealthchecksPingScript {slug = "article-export";}}
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "mawz";
      };
    };
  };
}
