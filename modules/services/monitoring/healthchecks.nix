{
  self,
  config,
  pkgs,
  ...
}: let
  port = 45566;
in {
  imports = [
    (self + /modules/systems/network/mount.nix)
    (self + /modules/sops.nix)
    (self + /modules/clients/healthchecks.nix)
  ];

  sops.secrets = {
    "healthchecks/local/secret-key" = {owner = config.services.healthchecks.user;};
    healthchecks-email = {
      owner = config.services.healthchecks.user;
      key = "email-notifications";
    };
  };

  services.healthchecks = {
    enable = true;
    listenAddress = "0.0.0.0";
    inherit port;
    settings = {
      SECRET_KEY_FILE = config.sops.secrets."healthchecks/local/secret-key".path;
      SITE_ROOT = "http://192.168.0.54:${toString port}";
      EMAIL_HOST = "smtp.gmail.com";
      EMAIL_PORT = "587";
      EMAIL_HOST_USER = "bercribe.notifications";
      EMAIL_HOST_PASSWORD_FILE = config.sops.secrets.healthchecks-email.path;
      EMAIL_USE_SSL = "False";
      EMAIL_USE_TLS = "True";
    };
  };
  networking.firewall.allowedTCPPorts = [port];

  # to restore backup, run
  # sudo cp <backup> /var/lib/healthchecks
  # sudo chown -R healthchecks:healthchecks /var/lib/healthchecks
  systemd.timers.healthchecks-backup = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "03:21";
      Unit = "healthchecks-backup.service";
    };
  };
  systemd.services.healthchecks-backup = {
    script = ''
      backupFile="healthchecks-backup-$(date +'%s').zip"
      systemctl stop healthchecks.service
      systemctl stop healthchecks-sendalerts.service
      systemctl stop healthchecks-sendreports.service
      ${pkgs.zip}/bin/zip -r "/tmp/$backupFile" ${config.services.healthchecks.dataDir}
      systemctl start healthchecks.target

      cp "/tmp/$backupFile" /mnt/mawz-nas/healthchecks/

      pingKey="$(cat ${config.sops.secrets."healthchecks/local/ping-key".path})"
      ${pkgs.curl}/bin/curl -m 10 --retry 5 --retry-connrefused "http://192.168.0.54:45566/ping/$pingKey/healthchecks-backup"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
