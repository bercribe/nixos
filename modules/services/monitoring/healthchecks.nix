{
  self,
  config,
  pkgs,
  local,
  ...
}: let
  utils = local.utils {inherit config;};
  port = 45566;
in {
  imports = [
    (self + /modules/services/postfix.nix)
  ];

  sops.secrets = {
    "healthchecks/local/secret-key" = {owner = config.services.healthchecks.user;};
  };

  services.healthchecks = {
    enable = true;
    listenAddress = "0.0.0.0";
    inherit port;
    dataDir = "/services/healthchecks";
    settings = {
      SECRET_KEY_FILE = config.sops.secrets."healthchecks/local/secret-key".path;
      SITE_ROOT = utils.getSiteRoot "healthchecks";
      EMAIL_HOST = "localhost";
      EMAIL_PORT = "25";
      EMAIL_USE_TLS = "False";
      DEFAULT_FROM_EMAIL = "Healthchecks <noreply@healthchecks.lan>";
    };
  };

  local.reverseProxy = {
    enable = true;
    services.healthchecks = {
      inherit port;
    };
  };
}
