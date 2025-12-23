{
  pkgs,
  config,
  local,
  ...
}: let
  utils = local.utils {inherit config;};
in {
  imports = [
    ../systems/network/rclone.nix
  ];

  local.healthchecks-secret.enable = true;

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
}
