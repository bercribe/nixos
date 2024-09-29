{
  self,
  config,
  pkgs,
  ...
}: let
  port = 13114;
in {
  imports = [
    (self + /modules/systems/network/mount.nix)
    (self + /modules/clients/local-healthchecks.nix)
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
      ${pkgs.zip}/bin/zip -r "/tmp/$backupFile" ${config.services.uptime-kuma.settings.DATA_DIR}
      systemctl start uptime-kuma

      cp "/tmp/$backupFile" /mnt/mawz-nas/uptime-kuma

      pingKey="$(cat ${config.sops.secrets."healthchecks/local/ping-key".path})"
      ${pkgs.curl}/bin/curl -m 10 --retry 5 --retry-connrefused "http://192.168.0.54:45566/ping/$pingKey/uptime-kuma-backup"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
