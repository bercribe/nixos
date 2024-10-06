{
  self,
  config,
  pkgs,
  lib,
  ...
}: let
  port = 13114;
  dataDir = "/services/uptime-kuma/";
in {
  imports = [
    ./postfix.nix
    (self + /modules/systems/network/mount.nix)
    (self + /modules/clients/local-healthchecks.nix)
  ];

  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "0.0.0.0";
      PORT = toString port;
      DATA_DIR = lib.mkForce dataDir;
    };
  };
  systemd.services.uptime-kuma.serviceConfig.ReadWritePaths = dataDir;

  networking.firewall.allowedTCPPorts = [80 port];
  services.caddy = {
    enable = true;
    virtualHosts."http://uptime-kuma.lan".extraConfig = ''
      reverse_proxy localhost:${toString port}
    '';
  };

  # to restore backup, run
  # sudo cp <backup> /var/lib/private/uptime-kuma
  # sudo chown -R uptime-kuma:uptime-kuma /var/lib/private/uptime-kuma
  # sudo ln -s private/uptime-kuma /var/lib/uptime-kuma
  systemd.timers.uptime-kuma-backup = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "05:21";
      Unit = "uptime-kuma-backup.service";
    };
  };
  systemd.services.uptime-kuma-backup = {
    script = ''
      backupFile="uptime-kuma-backup-$(date +'%s').zip"
      systemctl stop uptime-kuma
      ${pkgs.zip}/bin/zip -r "/tmp/$backupFile" ${dataDir}
      systemctl start uptime-kuma

      cp "/tmp/$backupFile" /mnt/mawz-nas/uptime-kuma

      pingKey="$(cat ${config.sops.secrets."healthchecks/local/ping-key".path})"
      ${pkgs.curl}/bin/curl -m 10 --retry 5 --retry-connrefused "http://healthchecks.lan/ping/$pingKey/uptime-kuma-backup"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
