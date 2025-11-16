{
  config,
  lib,
  ...
}: let
  cfg = config.local.service-monitoring;
in {
  imports = [
    ./gatus.nix
    ./healthchecks.nix
    ../../cron/heartbeat-healthchecks.nix
    ../../cron/email-healthchecks.nix
  ];

  options.local.service-monitoring = with lib;
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
      gatus = {
        shortName = "gatus";
        inherit hosts;
      };
      healthchecks = {
        shortName = "healthchecks";
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
