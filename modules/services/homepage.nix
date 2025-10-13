{
  config,
  lib,
  local,
  secrets,
  ...
}: let
  cfg = config.local.services.homepage-dashboard;
  utils = local.utils {inherit config;};
  port = 13242;
in {
  options.local.services.homepage-dashboard.enable = lib.mkEnableOption "homepage-dashboard";

  config = lib.mkIf cfg.enable {
    sops.secrets."healthchecks/local/api-key-ro" = {
      sopsFile = secrets + /sops/common.yaml;
    };
    sops.secrets."healthchecks/remote/api-key-ro" = {
      sopsFile = secrets + /sops/common.yaml;
    };
    sops.templates."homepage.env".content = ''
      HOMEPAGE_VAR_HEALTHCHECKS_LOCAL_API_KEY=${config.sops.placeholder."healthchecks/local/api-key-ro"}
      HOMEPAGE_VAR_HEALTHCHECKS_REMOTE_API_KEY=${config.sops.placeholder."healthchecks/remote/api-key-ro"}
    '';

    services.homepage-dashboard = {
      enable = true;
      listenPort = port;
      allowedHosts = utils.localHostUrlBase "homepage-dashboard";
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
              "Lazy Chinese" = [
                {
                  abbr = "LC";
                  href = "https://www.lazychinese.com/";
                  icon = "https://images.squarespace-cdn.com/content/v1/650274d4d2b34154b074e134/dfa9aa3d-c2fe-4e5a-8247-561554c464c8/favicon.ico?format=100w";
                }
              ];
            }
            {
              "Comprehensible Japanese" = [
                {
                  abbr = "CJ";
                  href = "https://cijapanese.com/";
                  icon = "https://cijapanese.com/realfavicon/favicon-32x32.png";
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
          hledger-web = "https://hledger.org/images/coins2-248.png";
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
