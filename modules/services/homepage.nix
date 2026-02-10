{
  config,
  lib,
  local,
  secrets,
  ...
}: let
  cfg = config.local.services.homepage-dashboard;
  utils = local.utils;
  port = 13242;
in {
  options.local.services.homepage-dashboard.enable = lib.mkEnableOption "homepage-dashboard";

  config = lib.mkIf cfg.enable {
    sops.secrets."healthchecks/local/api-key-ro" = {
      sopsFile = secrets + /sops/local.yaml;
    };
    sops.secrets."healthchecks/remote/api-key-ro" = {
      sopsFile = secrets + /sops/local.yaml;
    };
    sops.templates."homepage.env".content = ''
      HOMEPAGE_VAR_HEALTHCHECKS_LOCAL_API_KEY=${config.sops.placeholder."healthchecks/local/api-key-ro"}
      HOMEPAGE_VAR_HEALTHCHECKS_REMOTE_API_KEY=${config.sops.placeholder."healthchecks/remote/api-key-ro"}
    '';

    services.homepage-dashboard = {
      enable = true;
      listenPort = port;
      allowedHosts = utils.localHostServiceUrlBase "homepage-dashboard";
      settings = {
        layout = [
          {Productivity = {};}
          {Language = {};}
          {Hobbies = {};}
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
                  icon = "https://app.hey.com/favicon.ico";
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
              Github = [
                {
                  abbr = "GH";
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
              "Teatime Chinese" = [
                {
                  abbr = "CN";
                  href = "https://teatimechinese.com/teatime-chinese-podcast/";
                  icon = "https://teatimechinese.s3.amazonaws.com/wp-content/uploads/2022/06/12220228/cropped-logo-192x192.png";
                }
              ];
            }
            {
              "Yuyu no Nihongo" = [
                {
                  abbr = "JP";
                  href = "https://www.patreon.com/yuyujapanesepodcast";
                  icon = "https://c10.patreonusercontent.com/4/patreon-media/p/campaign/4587248/d025a1dee53a481db43fb4be1dc3fa20/eyJoIjozNjAsInciOjM2MH0%3D/2.png?token-hash=7o0FUVqcVSfugilXPghMfVqwluE3mbVq8f9mD20B36s%3D&token-time=1771977600";
                }
              ];
            }
          ];
        }
        {
          Hobbies = [
            {
              Keybr = [
                {
                  abbr = "KB";
                  href = "https://www.keybr.com/";
                  icon = "https://www.keybr.com/favicon.ico";
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
      ];
      services = let
        serviceEndpoint = service: let
          registryEntry = config.local.constants.service-registry."${service}";
          shortName = registryEntry.shortName;
          host = lib.head registryEntry.hosts;
        in "https://${shortName}.${utils.hostDomain host}";

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

        serviceName = service: config.local.constants.service-registry.${service}.friendlyName;
        mkService = {
          service,
          host ? lib.head config.local.constants.service-registry."${service}".hosts,
        }: let
          shortName = config.local.constants.service-registry."${service}".shortName;
          name = serviceName service;
        in {
          "${name}" = {
            href = "https://${shortName}.${utils.hostDomain host}";
            icon = icons."${service}" or name;
            description = "Running on ${host}";
            widget = lib.mkIf (widgets ? "${service}") widgets."${service}";
          };
        };

        homelabServices = with lib;
          config.local.constants.service-registry
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

        hostBookmarks = with lib;
          mapAttrsToList (host: {
            friendlyName,
            icon,
            ...
          }: {
            ${friendlyName} = {
              inherit icon;
              href = utils.hostUrl host;
              description = host;
            };
          }) (filterAttrs (_: {createBookmark, ...}: createBookmark) config.local.constants.hosts);
      in [
        {
          Homelab = homelabServices;
        }
        {
          Hosts = hostBookmarks;
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
