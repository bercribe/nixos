{
  self,
  config,
  pkgs,
  local,
  ...
}: let
  utils = local.utils {inherit config;};
in {
  sops.secrets."healthchecks/remote/ping-key" = {
    sopsFile = self + /secrets/common.yaml;
  };

  systemd.timers.uptime-heartbeat = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "uptime-heartbeat.service";
    };
  };
  systemd.services.uptime-heartbeat = {
    script = ''
      ${utils.writeRemoteHealthchecksPingScript "${config.networking.hostName}-online"}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
