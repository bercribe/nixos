{
  config,
  pkgs,
  ...
}: let
  port = 9044;
in {
  imports = [
    ../sops.nix
    ../systems/network/mount.nix
    ../clients/healthchecks.nix
  ];

  sops.secrets.miniflux-admin = {};

  services.miniflux = {
    enable = true;
    config = {
      PORT = toString port;
      BASE_URL = "http://192.168.0.54:${toString port}/";
      FETCH_YOUTUBE_WATCH_TIME = 1;
    };
    adminCredentialsFile = config.sops.secrets.miniflux-admin.path;
  };
  networking.firewall.allowedTCPPorts = [port];

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
      ${pkgs.curl}/bin/curl -m 10 --retry 5 --retry-connrefused "http://192.168.0.54:45566/ping/$pingKey/miniflux-backup"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
