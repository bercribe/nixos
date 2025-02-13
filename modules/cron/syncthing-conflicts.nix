{
  self,
  pkgs,
  config,
  scripts,
  local,
  ...
}: let
  utils = local.utils {inherit config;};
in {
  imports = [
    (self + /modules/clients/local-healthchecks.nix)
  ];

  systemd.timers.syncthing-conflicts = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "1d";
      OnUnitActiveSec = "1d";
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
      ${utils.writeHealthchecksCombinedScript "syncthing-conflicts" "python ${scripts}/check_sync_conflicts.py /zvault/syncthing"}
    '';
  };
}
