{
  pkgs,
  lib,
  config,
  local,
  ...
}: let
  cfg = config.local.cron.pcloud-gdrive-sync;
  utils = local.utils;
in {
  imports = [
    ../systems/network/rclone.nix
  ];

  options.local.cron.pcloud-gdrive-sync.enable = lib.mkEnableOption "pcloud gdrive sync";

  config = lib.mkIf cfg.enable {
    local.healthchecks-secret.enable = true;

    systemd.timers.pcloud-gdrive-sync = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "1h";
        OnUnitActiveSec = "1h";
        Unit = "pcloud-gdrive-sync.service";
      };
    };
    systemd.services.pcloud-gdrive-sync = {
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        ${pkgs.rclone}/bin/rclone --config ${config.sops.templates."rclone.conf".path} sync /zvault/syncthing/personal-cloud/passwords "gdrive:/passwords - external"

        ${utils.writeHealthchecksPingScript {slug = "pcloud-gdrive-sync";}}
      '';
    };
  };
}
