{config, ...}: let
  dataDir = "/zvault/services/immich";
in {
  services.immich = {
    enable = true;
    mediaLocation = dataDir;
  };

  local.reverseProxy = {
    enable = true;
    services.immich = {
      port = config.services.immich.port;
    };
  };
}
