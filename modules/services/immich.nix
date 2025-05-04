{
  config,
  lib,
  local,
  ...
}: let
  cfg = config.local.services.immich;
  utils = local.utils {inherit config;};
  dataDir = "/zvault/services/immich";

  shortName = config.local.service-registry.immich.shortName;
in {
  options.local.services.immich.enable = lib.mkEnableOption "immich";

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      mediaLocation = dataDir;
      settings = {
        server.externalDomain = utils.localHostUrl shortName;
        notifications.smtp = {
          enabled = true;
          from = ''"Immich Photo Server <noreply@immich.lan>"'';
          transport = {
            host = "localhost";
            port = 25;
          };
        };
      };
    };

    local.reverseProxy = {
      enable = true;
      services."${shortName}" = {
        port = config.services.immich.port;
      };
    };
  };
}
