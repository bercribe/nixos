{
  config,
  pkgs,
  lib,
  ...
}: let
  port = 13114;
in {
  imports = [
    ../systems/network/mawz-nas-ssh.nix
    ../clients/healthchecks.nix
  ];

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
      OnCalendar = "04:21";
      Unit = "uptime-kuma-backup.service";
    };
  };
  systemd.services.uptime-kuma-backup = {
    script = let
      identityFile = config.sops.secrets."mawz-nas/ssh/private".path;
    in ''
      systemctl stop uptime-kuma
      ${pkgs.rsync}/bin/rsync -az --delete -e "${pkgs.openssh}/bin/ssh -i ${identityFile}" ${config.services.uptime-kuma.settings.DATA_DIR} mawz@192.168.0.43:/volume1/mawz-home/uptime-kuma/
      systemctl start uptime-kuma

      pingKey="$(cat ${config.sops.secrets."healthchecks/local/ping-key".path})"
      ${pkgs.curl}/bin/curl -m 10 --retry 5 --retry-connrefused "http://192.168.0.54:45566/ping/$pingKey/uptime-kuma-backup"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    # prevents backup from being clobbered on a new system install
    # to restore backup, run
    # sudo cp <backup> /var/lib/private/uptime-kuma
    # sudo chown -R uptime-kuma:uptime-kuma /var/lib/private/uptime-kuma
    # sudo ln -s private/uptime-kuma /var/lib/uptime-kuma
    unitConfig.AssertPathExists = "/backups/config/uptime-kuma";
  };
}
