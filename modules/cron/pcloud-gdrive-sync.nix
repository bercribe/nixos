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
      ${pkgs.rclone}/bin/rclone --config ${config.sops.templates."rclone.conf".path} sync /zvault/syncthing/personal-cloud/docs "gdrive:/docs - external"
      ${pkgs.rclone}/bin/rclone --config ${config.sops.templates."rclone.conf".path} sync /zvault/syncthing/personal-cloud/passwords "gdrive:/passwords - external"

      ${utils.writeHealthchecksPingScript {slug = "pcloud-gdrive-sync";}}
    '';
  };
}
