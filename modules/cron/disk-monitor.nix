{
  pkgs,
  config,
  lib,
  local,
  secrets,
  ...
}: let
  cfg = config.local.cron.disk-monitor;
  utils = local.utils;
in {
  options.local.cron.disk-monitor = with lib;
  with types; {
    enable = mkEnableOption "disk monitor";
    headless = mkOption {
      type = bool;
      description = "True to send checks to healthchecks, false for desktop notifications";
    };
    zfs = mkOption {
      type = bool;
      description = "True to use zfs based disk checks, false for df";
    };
    remoteCheck = mkOption {
      type = bool;
      description = "True to use upstream healthchecks endpoint, false for local";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."healthchecks/remote/ping-key" = {
      sopsFile = secrets + /sops/common.yaml;
    };

    systemd.timers.disk-monitor = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "disk-monitor.service";
      };
    };
    systemd.services.disk-monitor = {
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = let
        zpool = "${pkgs.zfs}/bin/zpool";
        slug = "${config.networking.hostName}-disk-usage";
        failCap = 75;

        hcPing =
          if cfg.remoteCheck
          then utils.writeRemoteHealthchecksPingScript
          else utils.writeHealthchecksPingScript;
        hcLog =
          if cfg.remoteCheck
          then utils.writeRemoteHealthchecksLogScript
          else utils.writeHealthchecksLogScript;

        diskDesc =
          if cfg.zfs
          then "zpool $pool"
          else "mountpoint $mountpoint";
        iterator =
          if cfg.zfs
          then ''
            for pool in $(${zpool} list -H -o name); do
              capacity=$(${zpool} list -H -p -o capacity "$pool")
          ''
          else ''
            df -h -P | tail -n +2 | while read filesystem size used avail percent mountpoint; do
              capacity=''${percent%?}
          '';

        healthcheckLog = lib.optionalString cfg.headless ''${hcLog {inherit slug;}} "${diskDesc} capacity: $capacity%"'';
        healthcheckPing = lib.optionalString cfg.headless ''
          if [ "$fail" != true ]; then
            ${hcPing {inherit slug;}}
          fi
        '';

        systemNotif = lib.optionalString (!cfg.headless) ''${pkgs.util-linux}/bin/logger -t journal-notify "${diskDesc} capacity: $capacity%"'';
      in ''
        fail=false
        ${iterator}

          ${healthcheckLog}

          if [ "$capacity" -ge "${toString failCap}" ]; then
            fail=true
            ${systemNotif}
          fi
        done

        ${healthcheckPing}
      '';
    };
  };
}
