{
  pkgs,
  lib,
  config,
  local,
  ...
}: let
  cfg = config.local.cron.note-snapshot;
  utils = local.utils;
in {
  options.local.cron.note-snapshot.enable = lib.mkEnableOption "note snapshot";

  config = lib.mkIf cfg.enable {
    local.healthchecks-secret.enable = true;

    systemd.timers.note-snapshot = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "1d";
        OnUnitActiveSec = "1d";
        Unit = "note-snapshot.service";
      };
    };
    systemd.services.note-snapshot = {
      serviceConfig = {
        Type = "oneshot";
        User = "mawz";
      };
      path = [pkgs.openssh];
      script = let
        git = lib.getExe pkgs.git;
        git-resync = lib.getExe pkgs.errata.git-resync;
      in ''
        cd /zvault/syncthing/personal-cloud/external-brain/
        ${git} status &>/dev/null || ${git-resync} ssh://forgejo@${utils.plainUrl "forgejo"}/mawz/external-brain.git

        ${git} add .
        ${git} commit -m "autosnap: $(date)"
        ${git} pull --rebase
        ${git} push

        ${utils.writeHealthchecksPingScript {slug = "note-snapshot";}}
      '';
    };
  };
}
