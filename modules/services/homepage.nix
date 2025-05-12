{
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
    # TODO: use `allowedHosts` option after update
    sops.templates."homepage.env".content = ''
      HOMEPAGE_ALLOWED_HOSTS=${utils.localHostUrlBase "homepage-dashboard"}
    '';

    services.homepage-dashboard = {
      enable = true;
      listenPort = port;
      services = let
        icons = {
          paisa = "https://paisa.fyi/images/logo.svg";
        };

        serviceName = service: lib.defaultTo service config.local.service-registry."${service}".friendlyName;
        mkService = {
          service,
          host,
        }: let
          shortName = config.local.service-registry."${service}".shortName;
          name = serviceName service;
        in {
          "${name}" = {
            href = "https://${shortName}.${host}.mawz.dev";
            icon = icons."${service}" or name;
            description = "Running on ${host}";
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
                host = head hosts;
              }
            else {
              "${serviceName service}" =
                hosts
                |> map (host: mkService {inherit service host;});
            });
      in [
        {
          Homelab = homelabServices;
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
