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
        homelabServices = with lib;
          concatLists (mapAttrsToList (service: {
            shortName,
            friendlyName,
            hosts,
          }:
            map (host: {
              "${defaultTo service friendlyName}${
                if (length hosts > 1)
                then " | ${host}"
                else ""
              }" = {href = "https://${shortName}.${host}.mawz.dev";};
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
