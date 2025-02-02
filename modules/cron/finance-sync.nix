{
  self,
  pkgs,
  config,
  ...
}: let
  user = "finance-sync";
  group = "ledger";
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
      ${pkgs.nix}/bin/nix run scripts/

      pingKey="$(cat ${config.sops.secrets.finance-sync-ping-key.path})"
      ${pkgs.curl}/bin/curl -m 10 --retry 5 --retry-connrefused "http://healthchecks.lan/ping/$pingKey/finance-sync"
    '';
  };
  users.users."${user}" = {
    isSystemUser = true;
    inherit group;
    home = "/var/lib/finance-sync";
  };
  users.groups."${group}" = {};
}
