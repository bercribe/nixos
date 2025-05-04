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

  config = let
    hosts = [cfg.host];
  in {
    local.service-registry.healthchecks = {
      shortName = "healthchecks";
      inherit hosts;
    };
    local.service-registry.uptime-kuma = {
      shortName = "ukuma";
      inherit hosts;
    };

    local.cron = let
      isMonitoringHost = cfg.host == config.networking.hostName;
    in {
      heartbeat-healthchecks.enable = lib.mkDefault isMonitoringHost;
      email-healthchecks.enable = isMonitoringHost;
    };
  };
}
