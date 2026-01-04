{
  config,
  lib,
  local,
  secrets,
  ...
}: let
  cfg = config.local.services.gatus;
  port = 55310;

  utils = local.utils;
in {
  options.local.services.gatus.enable = lib.mkEnableOption "gatus";

  config = lib.mkIf cfg.enable {
    local.services.postfix.enable = true;
    local.cron.heartbeat-healthchecks.enable = true;
    local.cron.email-healthchecks.enable = true;

    sops.secrets."healthchecks/remote/ping-key" = {};
    sops.templates."gatus.env".content = ''
      UPSTREAM_HEALTHCHECKS_PING_KEY=${config.sops.placeholder."healthchecks/remote/ping-key"}
    '';

    services.gatus = {
      enable = true;
      settings = {
        web.port = port;
        alerting.email = {
          from = ''"Gatus" <noreply@gatus.lan>'';
          host = "localhost";
          port = 25;
          to = local.secrets.email;
          default-alert.description = utils.serviceUrl "gatus";
        };
        endpoints = let
          makeEndpoint = site:
            {
              conditions = ["[STATUS] == 200"];
              alerts = [
                {
                  type = "email";
                }
              ];
            }
            // site;

          customEndpoints = map makeEndpoint [
            {
              name = "portfolio";
              url = "https://mawz.dev";
              group = "public";
            }
            {
              name = "project zoran";
              url = "https://projectzoran.com";
              group = "public";
            }
            {
              name = "upstream healthchecks.io ping";
              url = "https://hc-ping.com/\${UPSTREAM_HEALTHCHECKS_PING_KEY}/gatus-online?create=1";
              group = "monitoring";
            }
          ];

          hostOverrides = {
            mr-president = {
              client.insecure = true;
            };
            hermit-purple = {
              conditions = ["[STATUS] == 401"];
            };
          };

          hostEndpoints = with lib;
            mapAttrsToList (host: {friendlyName, ...}:
              makeEndpoint ({
                  name = friendlyName;
                  url = utils.hostUrl host;
                  group = "hosts";
                }
                // (hostOverrides.${host} or {}))) (filterAttrs (_: {enableMonitoring, ...}: enableMonitoring) config.local.constants.hosts);

          registryOverrides = {
            kodi = {
              conditions = ["[STATUS] == 401"];
            };
          };

          registryEndpoints = with lib;
            concatLists (mapAttrsToList (service: {
              shortName,
              hosts,
              ...
            }:
              map (host: let
                isUnique = length hosts == 1;
              in
                makeEndpoint ({
                    name = "${service} (${host})";
                    group =
                      if isUnique
                      then host
                      else shortName;
                    url = "http://${shortName}${
                      if isUnique
                      then ""
                      else ".${host}"
                    }.lan";
                  }
                  // (registryOverrides.${service} or {})))
              hosts)
            config.local.constants.service-registry);
        in
          customEndpoints ++ hostEndpoints ++ registryEndpoints;
      };
      environmentFile = config.sops.templates."gatus.env".path;
    };

    local.reverseProxy = {
      enable = true;
      services.gatus.port = port;
    };
  };
}
