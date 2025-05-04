{
  self,
  config,
  pkgs,
  lib,
  local,
  ...
}: let
  cfg = config.local.services.forgejo;
  utils = local.utils {inherit config;};
  port = 54776;

  url = utils.localHostUrl "forgejo";
in {
  options.local.services.forgejo.enable = lib.mkEnableOption "forgejo";

  config = lib.mkIf cfg.enable {
    # mirroring my repos here with this:
    # https://forgejo.org/docs/latest/user/repo-mirror/
    services.forgejo = {
      enable = true;
      stateDir = "/services/forgejo";
      settings = {
        server = {
          HTTP_PORT = port;
          DOMAIN = url;
          ROOT_URL = url;
        };
      };
    };

    local.reverseProxy = {
      enable = true;
      services.forgejo = {
        inherit port;
      };
    };
  };
}
