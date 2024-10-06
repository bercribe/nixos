{
  self,
  config,
  pkgs,
  ...
}: let
  port = 45566;
in {
  imports = [
    ./postfix.nix
    (self + /modules/systems/network/mount.nix)
    (self + /modules/sops.nix)
    (self + /modules/clients/local-healthchecks.nix)
  ];

  sops.secrets = {
    "healthchecks/local/secret-key" = {owner = config.services.healthchecks.user;};
  };

  services.healthchecks = {
    enable = true;
    listenAddress = "0.0.0.0";
    inherit port;
    dataDir = "/services/healthchecks";
    settings = {
      SECRET_KEY_FILE = config.sops.secrets."healthchecks/local/secret-key".path;
      SITE_ROOT = "http://healthchecks.lan";
      EMAIL_HOST = "localhost";
      EMAIL_PORT = "25";
      EMAIL_USE_TLS = "False";
    };
  };

  networking.firewall.allowedTCPPorts = [80 port];
  services.caddy = {
    enable = true;
    virtualHosts."http://healthchecks.lan".extraConfig = ''
      reverse_proxy localhost:${toString port}
    '';
  };

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
      ${pkgs.curl}/bin/curl -m 10 --retry 5 --retry-connrefused "http://healthchecks.lan/ping/$pingKey/healthchecks-backup"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
