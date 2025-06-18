{
  self,
  config,
  pkgs,
  lib,
  local,
  ...
}: let
  utils = local.utils {inherit config;};
in {
  local.services.postfix.enable = true;

  sops.secrets."readeck/email-digest/receiver" = {};
  sops.secrets."readeck/email-digest/api-key" = {};

  systemd.timers.email-digest = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "9:00:00";
      Unit = "email-digest.service";
    };
  };
  systemd.services.email-digest = {
    script = ''
      receiver="$(cat ${config.sops.secrets."readeck/email-digest/receiver".path})"
      key="$(cat ${config.sops.secrets."readeck/email-digest/api-key".path})"

      response="$(${lib.getExe pkgs.curl} -X GET "${utils.serviceUrl "readeck"}/api/bookmarks?is_archived=false" -H "accept: application/json" -H "Authorization: Bearer $key")"

      links="$(echo $response | ${lib.getExe pkgs.jq} -r '.[] | "[\(.title)](\(.url)) (\(.reading_time) min)\n"')"
      html=$(echo "### Links:
      $links
      " | ${lib.getExe pkgs.pandoc} -f markdown -t html)

      (
        echo "From: Readeck <noreply@readeck.lan>"
        echo "Subject: Readeck digest"
        echo "Content-Type: text/html"
        echo
        echo $html
      ) | ${pkgs.postfix}/bin/sendmail $receiver
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
