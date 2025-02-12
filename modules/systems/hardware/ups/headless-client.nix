{
  self,
  config,
  pkgs,
  local,
  ...
}: let
  utils = local.utils {inherit config;};
in {
  imports = [
    ./base-client.nix
    (self + /modules/clients/local-healthchecks.nix)
  ];

  systemd.timers.ups-monitor = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "ups-monitor.service";
    };
  };
  systemd.services.ups-monitor = {
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      # will error out if not connected
      ${pkgs.nut}/bin/upsc ups@judgement.mawz.dev

      ${utils.writeHealthchecksPingScript "${config.networking.hostName}-ups-online"}
    '';
  };
}
