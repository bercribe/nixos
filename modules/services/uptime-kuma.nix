{
  config,
  pkgs,
  lib,
  ...
}: let
  port = 13114;
in {
  imports = [../network/mawz-nas-ssh.nix];

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
    script = let
      identityFile = config.sops.secrets."mawz-nas/ssh/private".path;
    in ''
      ${pkgs.rsync}/bin/rsync -a --delete -e "${pkgs.openssh}/bin/ssh -i ${identityFile}" ${config.services.uptime-kuma.settings.DATA_DIR} mawz@192.168.0.43:/volume1/mawz-home/uptime-kuma/
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
