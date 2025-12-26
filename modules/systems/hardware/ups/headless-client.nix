{
  config,
  pkgs,
  local,
  ...
}: let
  utils = local.utils;
in {
  imports = [
    ./base-client.nix
  ];
  local.healthchecks-secret.enable = true;

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
      ${pkgs.nut}/bin/upsc ups@${utils.hostDomain "judgement"}

      ${utils.writeHealthchecksPingScript {slug = "${config.networking.hostName}-ups-online";}}
    '';
  };
}
