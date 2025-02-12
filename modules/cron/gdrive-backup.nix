{
  self,
  pkgs,
  config,
  local,
  ...
}: let
  utils = local.utils {inherit config;};
in {
  imports = [
    (self + /modules/clients/local-healthchecks.nix)
    (self + /modules/clients/rclone.nix)
  ];

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

      ${utils.writeHealthchecksPingScript "gdrive-backup"}
    '';
  };
}
