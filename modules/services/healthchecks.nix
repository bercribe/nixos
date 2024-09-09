{
  config,
  pkgs,
  lib,
  ...
}: let
  port = 45566;
in {
  imports = [
    ../systems/network/mawz-nas-ssh.nix
    ../sops.nix
    ../clients/healthchecks.nix
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

  systemd.timers.healthchecks-backup = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "04:22";
      Unit = "healthchecks-backup.service";
    };
  };
  systemd.services.healthchecks-backup = {
    script = let
      identityFile = config.sops.secrets."mawz-nas/ssh/private".path;
    in ''
      systemctl stop healthchecks.service
      systemctl stop healthchecks-sendalerts.service
      systemctl stop healthchecks-sendreports.service
      ${pkgs.rsync}/bin/rsync -az --delete -e "${pkgs.openssh}/bin/ssh -i ${identityFile}" ${config.services.healthchecks.dataDir}/ mawz@192.168.0.43:/volume1/mawz-home/healthchecks/
      systemctl start healthchecks.target

      sleep 10
      pingKey="$(cat ${config.sops.secrets."healthchecks/local/ping-key".path})"
      ${pkgs.curl}/bin/curl -m 10 --retry 5 "http://192.168.0.54:45566/ping/$pingKey/healthchecks-backup"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    # prevents backup from being clobbered on a new system install
    # to restore backup, run
    # sudo cp <backup> /var/lib/healthchecks
    # sudo chown -R healthchecks:healthchecks /var/lib/healthchecks
    unitConfig.AssertPathExists = "/backups/config/healthchecks";
  };
}
