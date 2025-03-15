{config, ...}: let
  dataDir = "/zvault/services/immich";
in {
  services.immich = {
    enable = true;
    mediaLocation = dataDir;
    settings = {
      server.externalDomain = "http://immich.lan";
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
}
