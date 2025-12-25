{
  pkgs,
  lib,
  config,
  local,
  ...
}: let
  cfg = config.local.cron.echoes-backup;
  utils = local.utils;
in {
  options.local.cron.echoes-backup.enable = lib.mkEnableOption "echoes backup";

  config = lib.mkIf cfg.enable {
    local.healthchecks-secret.enable = true;
    local.rclone.enable = true;

    systemd.timers.echoes-backup = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "1h";
        OnUnitActiveSec = "1h";
        Unit = "echoes-backup.service";
      };
    };
    systemd.services.echoes-backup = {
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        ${pkgs.rclone}/bin/rclone --config ${config.sops.templates."rclone.conf".path} sync echoes: /zvault/backups/echoes

        ${utils.writeHealthchecksPingScript {slug = "echoes-backup";}}
      '';
    };
  };
}
