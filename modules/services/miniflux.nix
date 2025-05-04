{
  self,
  config,
  pkgs,
  lib,
  local,
  ...
}: let
  cfg = config.local.services.miniflux;
  utils = local.utils {inherit config;};

  port = 9044;
in {
  options.local.services.miniflux.enable = lib.mkEnableOption "miniflux";

  config = lib.mkIf cfg.enable {
    sops.secrets.miniflux-admin = {};

    services.miniflux = {
      enable = true;
      config = {
        PORT = toString port;
        BASE_URL = utils.localHostUrl "miniflux";
        FETCH_YOUTUBE_WATCH_TIME = 1;
        # tuning
        POLLING_FREQUENCY = 5; # minutes
        BATCH_SIZE = 4; # num feeds / 288, so everything gets refreshed every 24 hours
      };
      adminCredentialsFile = config.sops.secrets.miniflux-admin.path;
    };

    local.reverseProxy = {
      enable = true;
      services.miniflux = {
        inherit port;
      };
    };
  };
}
