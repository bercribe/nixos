{
  self,
  config,
  pkgs,
  ...
}: let
  port = 9044;
in {
  imports = [
    (self + /modules/sops.nix)
  ];

  sops.secrets.miniflux-admin = {};

  services.miniflux = {
    enable = true;
    config = {
      PORT = toString port;
      BASE_URL = "https://miniflux.${config.networking.hostName}.mawz.dev/";
      FETCH_YOUTUBE_WATCH_TIME = 1;
    };
    adminCredentialsFile = config.sops.secrets.miniflux-admin.path;
  };
  services.postgresql.dataDir = "/services/postgres/${config.services.postgresql.package.psqlSchema}";

  services.reverseProxy = {
    enable = true;
    services.miniflux = {
      inherit port;
    };
  };
}
