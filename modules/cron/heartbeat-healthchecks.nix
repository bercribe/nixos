{
  config,
  lib,
  local,
  secrets,
  ...
}: let
  cfg = config.local.cron.heartbeat-healthchecks;
  utils = local.utils {inherit config;};
in {
  options.local.cron.heartbeat-healthchecks.enable = lib.mkEnableOption "heartbeat healthchecks";

  config = lib.mkIf cfg.enable {
    sops.secrets."healthchecks/remote/ping-key" = {
      sopsFile = secrets + /sops/common.yaml;
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
        ${utils.writeRemoteHealthchecksPingScript {slug = "${config.networking.hostName}-online";}}
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };
}
