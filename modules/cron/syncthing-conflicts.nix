{
  self,
  pkgs,
  config,
  scripts,
  ...
}: {
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
      python ${scripts}/check_sync_conflicts.py /zvault/syncthing

      pingKey="$(cat ${config.sops.secrets."healthchecks/local/ping-key".path})"
      ${pkgs.curl}/bin/curl -m 10 --retry 5 --retry-connrefused "http://healthchecks.lan/ping/$pingKey/syncthing-conflicts"
    '';
  };
}
