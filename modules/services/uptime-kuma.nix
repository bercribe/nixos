{
  config,
  pkgs,
  lib,
  ...
}: let
  port = 13114;
in {
  # notifications set up with a gmail burner
  # password set here: https://myaccount.google.com/apppasswords
  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "0.0.0.0";
      PORT = toString port;
    };
  };
  networking.firewall.allowedTCPPorts = [port];

  systemd.timers.uptime-kuma-backup = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "uptime-kuma-backup.service";
    };
  };
  systemd.services.uptime-kuma-backup = {
    script = ''
      ${pkgs.rsync}/bin/rsync -a --delete ${config.services.uptime-kuma.settings.DATA_DIR} /mnt/mawz-nas/uptime-kuma/
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
