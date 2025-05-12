{
  self,
  config,
  lib,
  local,
  ...
}: let
  cfg = config.local.services.homepage-dashboard;
  utils = local.utils {inherit config;};
  port = 13242;
in {
  options.local.services.homepage-dashboard.enable = lib.mkEnableOption "homepage-dashboard";

  config = lib.mkIf cfg.enable {
    sops.secrets."healthchecks/local/api-key-ro" = {
      sopsFile = self + /secrets/common.yaml;
    };
    sops.secrets."healthchecks/remote/api-key-ro" = {
      sopsFile = self + /secrets/common.yaml;
    };
    # TODO: use `allowedHosts` option after update
    sops.templates."homepage.env".content = ''
      HOMEPAGE_ALLOWED_HOSTS=${utils.localHostUrlBase "homepage-dashboard"}
      HOMEPAGE_VAR_HEALTHCHECKS_LOCAL_API_KEY=${config.sops.placeholder."healthchecks/local/api-key-ro"}
      HOMEPAGE_VAR_HEALTHCHECKS_REMOTE_API_KEY=${config.sops.placeholder."healthchecks/remote/api-key-ro"}
    '';

    services.homepage-dashboard = {
      enable = true;
      listenPort = port;
      settings = {
        layout = [
          {Productivity = {};}
          {Entertainment = {};}
          {Coding = {};}
          {Language = {};}
        ];
      };
      bookmarks = [
        {
          Productivity = [
            {
              TickTick = [
                {
                  abbr = "TT";
                  href = "https://ticktick.com/";
                }
              ];
            }
            {
              Hey = [
                {
                  abbr = "HE";
                  href = "https://app.hey.com/";
                }
              ];
            }
            {
              Calendar = [
                {
                  abbr = "GC";
                  href = "https://calendar.google.com/";
                  icon = "google-calendar";
                }
              ];
            }
            {
              Drive = [
                {
                  abbr = "GD";
                  href = "https://drive.google.com/";
                  icon = "google-drive";
                }
              ];
            }
          ];
        }
        {
          Entertainment = [
            {
              Pocket = [
                {
                  abbr = "GP";
                  href = "https://getpocket.com/";
                }
              ];
            }
            {
              Raindrop = [
                {
                  abbr = "RD";
                  href = "https://app.raindrop.io/";
                }
              ];
            }
            {
              Chess = [
                {
                  abbr = "CH";
                  href = "https://www.chess.com/";
                  icon = "https://www.chess.com/favicon.ico";
                }
              ];
            }
          ];
        }
        {
          Coding = [
            {
              Github = [
                {
                  abbr = "GitHub";
                  href = "https://github.com/";
                  icon = "github";
                }
              ];
            }
          ];
        }
        {
          Language = [
            {
              Bunpro = [
                {
                  abbr = "BP";
                  href = "https://bunpro.jp/";
                  icon = "https://bunpro.jp/favicon.ico";
                }
              ];
            }
          ];
        }
      ];
      services = let
        serviceEndpoint = service: let
          registryEntry = config.local.service-registry."${service}";
          shortName = registryEntry.shortName;
          host = lib.head registryEntry.hosts;
        in "https://${shortName}.${host}.mawz.dev";

        icons = {
          paisa = "https://paisa.fyi/images/logo.svg";
        };
        widgets = {
          gatus = {
            type = "gatus";
            url = serviceEndpoint "gatus";
          };
          healthchecks = {
            type = "healthchecks";
            url = serviceEndpoint "healthchecks";
            key = "{{HOMEPAGE_VAR_HEALTHCHECKS_LOCAL_API_KEY}}";
          };
        };

        serviceName = service: lib.defaultTo service config.local.service-registry."${service}".friendlyName;
        mkService = {
          service,
          host ? lib.head config.local.service-registry."${service}".hosts,
        }: let
          shortName = config.local.service-registry."${service}".shortName;
          name = serviceName service;
        in {
          "${name}" = {
            href = "https://${shortName}.${host}.mawz.dev";
            icon = icons."${service}" or name;
            description = "Running on ${host}";
            widget = lib.mkIf (widgets ? "${service}") widgets."${service}";
          };
        };

        homelabServices = with lib;
          config.local.service-registry
          |> mapAttrsToList (service: {
            shortName,
            friendlyName,
            hosts,
          }:
            if length hosts == 1
            then
              mkService {
                inherit service;
              }
            else {
              "${serviceName service}" =
                hosts
                |> map (host: mkService {inherit service host;});
            });

        monitoringServices = [
          (mkService {service = "gatus";})
          (mkService {service = "healthchecks";})
          {
            "upstream healthchecks" = let
              url = "https://healthchecks.io/";
            in {
              href = url;
              icon = "healthchecks";
              widget = {
                type = "healthchecks";
                inherit url;
                key = "{{HOMEPAGE_VAR_HEALTHCHECKS_REMOTE_API_KEY}}";
              };
            };
          }
        ];
      in [
        {
          Homelab = homelabServices;
        }
        {
          Monitoring = monitoringServices;
        }
      ];
      environmentFile = config.sops.templates."homepage.env".path;
    };

    local.reverseProxy = {
      enable = true;
      services.homepage-dashboard.port = port;
    };
  };
}
