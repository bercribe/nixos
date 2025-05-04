{
  self,
  config,
  pkgs,
  lib,
  local,
  ...
}: let
  cfg = config.local.services.healthchecks;
  utils = local.utils {inherit config;};
  port = 45566;
in {
  options.local.services.healthchecks.enable = lib.mkEnableOption "healthchecks";

  config = lib.mkIf cfg.enable {
    local.services.postfix.enable = true;

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
        SITE_ROOT = utils.localHostUrl "healthchecks";
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
  };
}
