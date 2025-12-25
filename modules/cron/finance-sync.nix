{
  config,
  pkgs,
  lib,
  local,
  secrets,
  ...
}: let
  cfg = config.local.cron.finance-sync;

  user = "finance-sync";
  group = "ledger";

  utils = local.utils;
in {
  options.local.cron.finance-sync.enable = lib.mkEnableOption "finance sync";

  config = lib.mkIf cfg.enable {
    sops.secrets.finance-sync-ping-key = {
      key = "healthchecks/local/ping-key";
      sopsFile = secrets + /sops/local.yaml;
      owner = user;
    };

    systemd.timers.finance-sync = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "1d";
        OnUnitActiveSec = "1d";
        Unit = "finance-sync.service";
      };
    };
    systemd.services.finance-sync = {
      serviceConfig = {
        Type = "oneshot";
        User = user;
        Group = group;
        WorkingDirectory = "/zvault/shared/finances";
        StateDirectory = "finance-sync";
      };
      script = ''
        ${utils.writeHealthchecksCombinedScript {
          slug = "finance-sync";
          secret = "finance-sync-ping-key";
        } "${pkgs.nix}/bin/nix run scripts/"}
      '';
    };
    users.users."${user}" = {
      isSystemUser = true;
      inherit group;
      home = "/var/lib/finance-sync";
    };
    users.groups."${group}" = {};
  };
}
