{
  config,
  lib,
  ...
}: let
  cfg = config.local.services.homepage-dashboard;
  port = 13242;
in {
  options.local.services.homepage-dashboard.enable = lib.mkEnableOption "homepage-dashboard";

  config = lib.mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      listenPort = port;
      services = let
        icons = {
          paisa = "https://paisa.fyi/images/logo.svg";
        };
        homelabServices = with lib;
          concatLists (mapAttrsToList (service: {
            shortName,
            friendlyName,
            hosts,
          }: let
            name = lib.defaultTo service friendlyName;
          in
            map (host: {
              "${name}${
                if (length hosts > 1)
                then " | ${host}"
                else ""
              }" = {
                href = "https://${shortName}.${host}.mawz.dev";
                icon = icons."${service}" or name;
              };
            })
            hosts)
          config.local.service-registry);
      in [
        {
          Homelab = homelabServices;
        }
      ];
    };

    local.reverseProxy = {
      enable = true;
      services.homepage-dashboard.port = port;
    };
  };
}
