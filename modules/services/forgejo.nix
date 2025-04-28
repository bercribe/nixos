{
  self,
  config,
  pkgs,
  local,
  ...
}: let
  utils = local.utils {inherit config;};
  port = 54776;
in {
  # mirroring my repos here with this:
  # https://forgejo.org/docs/latest/user/repo-mirror/
  services.forgejo = {
    enable = true;
    stateDir = "/services/forgejo";
    settings = {
      server = {
        HTTP_PORT = port;
        DOMAIN = utils.getSiteRoot "forgejo";
        ROOT_URL = utils.getSiteRoot "forgejo";
      };
    };
  };

  local.reverseProxy = {
    enable = true;
    services.forgejo = {
      inherit port;
    };
  };
}
