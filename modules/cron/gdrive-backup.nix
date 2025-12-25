{
  pkgs,
  config,
  local-utils,
  ...
}: let
  utils = local-utils;
in {
  imports = [
    ../systems/network/rclone.nix
  ];

  local.healthchecks-secret.enable = true;

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
}
