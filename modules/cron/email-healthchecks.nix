{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.local.cron.email-healthchecks;
in {
  options.local.cron.email-healthchecks.enable = lib.mkEnableOption "email healthchecks";

  config = lib.mkIf cfg.enable {
    local.services.postfix.enable = true;

    sops.secrets."healthchecks/remote/email-receiver" = {};

    systemd.timers.email-heartbeat = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "1h";
        OnUnitActiveSec = "1h";
        Unit = "email-heartbeat.service";
      };
    };
    systemd.services.email-heartbeat = {
      script = ''
        receiver="$(cat ${config.sops.secrets."healthchecks/remote/email-receiver".path})"
        echo "Email notifs good!" | ${pkgs.postfix}/bin/sendmail $receiver
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };
}
