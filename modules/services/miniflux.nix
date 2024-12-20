{
  self,
  config,
  pkgs,
  ...
}: let
  port = 9044;
in {
  imports = [
    (self + /modules/sops.nix)
    (self + /modules/systems/network/mount.nix)
    (self + /modules/clients/local-healthchecks.nix)
  ];

  sops.secrets.miniflux-admin = {};

  services.miniflux = {
    enable = true;
    config = {
      PORT = toString port;
      BASE_URL = "http://miniflux.lan/";
      FETCH_YOUTUBE_WATCH_TIME = 1;
    };
    adminCredentialsFile = config.sops.secrets.miniflux-admin.path;
  };
  services.postgresql.dataDir = "/services/postgres/${config.services.postgresql.package.psqlSchema}";

  networking.firewall.allowedTCPPorts = [80 port];
  services.caddy = {
    enable = true;
    virtualHosts."http://miniflux.lan".extraConfig = ''
      reverse_proxy localhost:${toString port}
    '';
  };

  # to restore backup, run
  # psql miniflux < miniflux.dump
  systemd.timers.miniflux-backup = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "04:21";
      Unit = "miniflux-backup.service";
    };
  };
  systemd.services.miniflux-backup = {
    script = ''
      backupFile="miniflux-backup-$(date +'%s').dump"
      ${pkgs.postgresql}/bin/pg_dump -d miniflux -f /mnt/mawz-nas/miniflux/"$backupFile"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "miniflux";
    };
    onSuccess = ["miniflux-backup-notify.service"];
  };
  systemd.services.miniflux-backup-notify = {
    script = ''
      pingKey="$(cat ${config.sops.secrets."healthchecks/local/ping-key".path})"
      ${pkgs.curl}/bin/curl -m 10 --retry 5 --retry-connrefused "http://healthchecks.lan/ping/$pingKey/miniflux-backup"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
