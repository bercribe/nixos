{
  self,
  config,
  lib,
  ...
}: let
  cfg = config.local.services.monitoring;
in {
  imports = [
    ./healthchecks.nix
    ./uptime-kuma.nix
    (self + /modules/cron/heartbeat-healthchecks.nix)
    (self + /modules/cron/email-healthchecks.nix)
  ];

  options.local.services.monitoring = with lib;
  with types; {
    host = mkOption {
      type = str;
      description = "Hostname of machine running monitoring stack";
    };
  };

  config = {
    local.service-registry = let
      hosts = [cfg.host];
    in {
      healthchecks = {
        shortName = "healthchecks";
        inherit hosts;
      };
      uptime-kuma = {
        shortName = "ukuma";
        inherit hosts;
      };
    };

    local.cron = let
      isMonitoringHost = cfg.host == config.networking.hostName;
    in
      lib.mkIf isMonitoringHost {
        heartbeat-healthchecks.enable = true;
        email-healthchecks.enable = true;
      };
  };
}
