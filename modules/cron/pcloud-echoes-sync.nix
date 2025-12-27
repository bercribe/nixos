{
  pkgs,
  lib,
  config,
  local,
  ...
}: let
  cfg = config.local.cron.pcloud-echoes-sync;
  utils = local.utils;
in {
  options.local.cron.pcloud-echoes-sync.enable = lib.mkEnableOption "pcloud echoes sync";

  config = lib.mkIf cfg.enable {
    local.healthchecks-secret.enable = true;
    local.rclone.enable = true;

    systemd.timers.pcloud-echoes-sync = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "1h";
        OnUnitActiveSec = "1h";
        Unit = "pcloud-echoes-sync.service";
      };
    };
    systemd.services.pcloud-echoes-sync = {
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        ${pkgs.rclone}/bin/rclone --config ${config.sops.templates."rclone.conf".path} sync /zvault/syncthing/personal-cloud/passwords "echoes:/passwords - external"

        ${utils.writeHealthchecksPingScript {slug = "pcloud-echoes-sync";}}
      '';
    };
  };
}
