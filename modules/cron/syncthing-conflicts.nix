{
  config,
  pkgs,
  lib,
  local,
  ...
}: let
  cfg = config.local.cron.syncthing-conflicts;
  utils = local.utils;
in {
  options.local.cron.syncthing-conflicts.enable = lib.mkEnableOption "syncthing conflicts";

  config = lib.mkIf cfg.enable {
    local.healthchecks-secret.enable = true;

    systemd.timers.syncthing-conflicts = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "1h";
        OnUnitActiveSec = "1h";
        Unit = "syncthing-conflicts.service";
      };
    };
    systemd.services.syncthing-conflicts = {
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        ${utils.writeHealthchecksCombinedScript {slug = "syncthing-conflicts";} "${lib.getExe pkgs.check-sync-conflicts} /zvault/syncthing --no-colors"}
      '';
    };
  };
}
