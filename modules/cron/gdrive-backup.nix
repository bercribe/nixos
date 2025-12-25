{
  pkgs,
  lib,
  config,
  local,
  ...
}: let
  cfg = config.local.cron.gdrive-backup;
  utils = local.utils;
in {
  options.local.cron.gdrive-backup.enable = lib.mkEnableOption "gdrive backup";

  config = lib.mkIf cfg.enable {
    local.healthchecks-secret.enable = true;
    local.rclone.enable = true;

    systemd.timers.gdrive-backup = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "1h";
        OnUnitActiveSec = "1h";
        Unit = "gdrive-backup.service";
      };
    };
    systemd.services.gdrive-backup = {
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        ${pkgs.rclone}/bin/rclone --config ${config.sops.templates."rclone.conf".path} sync gdrive: /zvault/backups/gdrive

        ${utils.writeHealthchecksPingScript {slug = "gdrive-backup";}}
      '';
    };
  };
}
