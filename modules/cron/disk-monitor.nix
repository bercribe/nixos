{
  pkgs,
  config,
  lib,
  local,
  ...
}: let
  cfg = config.local.disk-monitor;
  utils = local.utils;
in {
  options.local.disk-monitor = with lib;
  with types; {
    enable = mkEnableOption "disk monitor";
    headless = mkOption {
      type = bool;
      description = "True to send checks to healthchecks, false for desktop notifications";
    };
  };

  config = lib.mkIf cfg.enable {
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
      in ''
        fail=false
        for pool in $(${zpool} list -H -o name); do
          capacity=$(${zpool} list -H -p -o capacity "$pool")

          ${
          if cfg.headless
          then ''${utils.writeHealthchecksLogScript {inherit slug;}} "$pool capacity: $capacity%"''
          else ""
        }

          if [ "$capacity" -ge "${toString failCap}" ]; then
            fail=true
            ${
          if !cfg.headless
          then ''${pkgs.util-linux}/bin/logger -t journal-notify "zpool $pool capacity: $capacity%"''
          else ""
        }
          fi
        done

        ${
          if cfg.headless
          then ''
            if [ "$fail" != true ]; then
              ${utils.writeHealthchecksPingScript {inherit slug;}}
            fi
          ''
          else ""
        }
      '';
    };
  };
}
