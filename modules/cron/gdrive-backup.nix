{
  self,
  pkgs,
  config,
  ...
}: {
  imports = [
    (self + /modules/clients/local-healthchecks.nix)
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

      pingKey="$(cat ${config.sops.secrets."healthchecks/local/ping-key".path})"
      ${pkgs.curl}/bin/curl -m 10 --retry 5 --retry-connrefused "http://healthchecks.lan/ping/$pingKey/gdrive-backup"
    '';
  };
}
