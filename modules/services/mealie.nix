{
  config,
  lib,
  ...
}: let
  cfg = config.local.services.mealie;
  port = 19639;
  dataDir = "/services/mealie";
in {
  options.local.services.mealie.enable = lib.mkEnableOption "mealie";

  config = lib.mkIf cfg.enable {
    services.mealie = {
      enable = true;
      inherit port;
    };

    systemd.services.mealie.environment.DATA_DIR = lib.mkForce dataDir;
    systemd.services.mealie.serviceConfig.StateDirectory = lib.mkForce null;
    systemd.services.mealie.serviceConfig.DynamicUser = lib.mkForce false;
    systemd.services.mealie.serviceConfig.User = "mealie";
    systemd.services.mealie.serviceConfig.Group = "mealie";
    users.groups.mealie = {};
    users.users.mealie = {
      isSystemUser = true;
      group = "mealie";
    };

    local.reverseProxy = {
      enable = true;
      services.mealie = {
        inherit port;
      };
    };
  };
}
