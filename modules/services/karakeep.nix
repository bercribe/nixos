{
  config,
  lib,
  local,
  ...
}: let
  cfg = config.local.services.karakeep;
  utils = local.utils {inherit config;};

  port = 43463;
  dataDir = "/services/karakeep";
in {
  options.local.services.karakeep.enable = lib.mkEnableOption "karakeep";

  config = lib.mkIf cfg.enable {
    services.karakeep = {
      enable = true;
      extraEnvironment = {
        PORT = toString port;
        NEXTAUTH_URL = utils.localHostUrl "karakeep";
      };
    };

    # https://github.com/systemd/systemd/issues/25097
    systemd.tmpfiles.settings.karakeep = {
      "/var/lib/karakeep"."L+".argument = dataDir;
    };
    systemd.services.karakeep-init.serviceConfig.BindPaths = "${dataDir}:/var/lib/karakeep";
    systemd.services.karakeep-workers.serviceConfig.BindPaths = "${dataDir}:/var/lib/karakeep";
    systemd.services.karakeep-web.serviceConfig.BindPaths = "${dataDir}:/var/lib/karakeep";
    systemd.services.karakeep-init.serviceConfig.StateDirectory = lib.mkForce null;
    systemd.services.karakeep-workers.serviceConfig.StateDirectory = lib.mkForce null;
    systemd.services.karakeep-web.serviceConfig.StateDirectory = lib.mkForce null;
    systemd.services.karakeep-init.environment.STATE_DIRECTORY = dataDir;

    local.reverseProxy = {
      enable = true;
      services.karakeep = {
        inherit port;
      };
    };
  };
}
