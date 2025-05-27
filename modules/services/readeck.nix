{
  config,
  lib,
  local,
  ...
}: let
  cfg = config.local.services.readeck;

  port = 34565;
  dataDir = "/services/readeck";
in {
  options.local.services.readeck.enable = lib.mkEnableOption "readeck";

  config = lib.mkIf cfg.enable {
    sops.secrets."readeck/secret" = {};
    sops.templates."readeck.env".content = ''
      READECK_SECRET_KEY=${config.sops.placeholder."readeck/secret"}
    '';

    services.readeck = {
      enable = true;
      environmentFile = config.sops.templates."readeck.env".path;
      settings = {
        main = {
          log_level = "info";
          secret_key = ""; # overwrite with env var
          data_directory = dataDir;
        };
        server = {
          host = "0.0.0.0";
          inherit port;
        };
        database = {
          source = "sqlite3:${dataDir}/db.sqlite3";
        };
      };
    };

    # https://github.com/systemd/systemd/issues/25097
    systemd.tmpfiles.settings.readeck = {
      "/var/lib/readeck"."L+".argument = dataDir;
    };
    systemd.services.readeck.serviceConfig.BindPaths = "${dataDir}:/var/lib/readeck";
    systemd.services.readeck.serviceConfig.StateDirectory = lib.mkForce null;
    systemd.services.readeck.serviceConfig.DynamicUser = lib.mkForce false;
    systemd.services.readeck.serviceConfig.User = "readeck";
    systemd.services.readeck.serviceConfig.Group = "readeck";
    users.groups.readeck = {};
    users.users.readeck = {
      isSystemUser = true;
      group = "readeck";
    };

    local.reverseProxy = {
      enable = true;
      services.readeck = {
        inherit port;
      };
    };
  };
}
