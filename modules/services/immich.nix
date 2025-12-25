{
  config,
  lib,
  local-utils,
  ...
}: let
  cfg = config.local.services.immich;
  utils = local-utils;
  dataDir = "/zvault/services/immich";
in {
  options.local.services.immich.enable = lib.mkEnableOption "immich";

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      mediaLocation = dataDir;
      settings = {
        server.externalDomain = utils.localHostUrl "immich";
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
      services.immich = {
        port = config.services.immich.port;
      };
    };
  };
}
