{
  self,
  pkgs,
  config,
  local,
  ...
}: let
  user = "finance-sync";
  group = "ledger";

  utils = local.utils {inherit config;};
in {
  sops.secrets.finance-sync-ping-key = {
    key = "healthchecks/local/ping-key";
    sopsFile = self + /secrets/common.yaml;
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
      ${utils.writeHealthchecksCombinedScript "finance-sync" "${pkgs.nix}/bin/nix run scripts/"}
    '';
  };
  users.users."${user}" = {
    isSystemUser = true;
    inherit group;
    home = "/var/lib/finance-sync";
  };
  users.groups."${group}" = {};
}
