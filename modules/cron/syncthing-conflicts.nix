{
  pkgs,
  config,
  local,
  ...
}: let
  utils = local.utils {inherit config;};
in {
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
    path = with pkgs; [python3 difftastic];
    script = ''
      ${utils.writeHealthchecksCombinedScript {slug = "syncthing-conflicts";} "python ${pkgs.errata}/check_sync_conflicts.py /zvault/syncthing --no-colors"}
    '';
  };
}
