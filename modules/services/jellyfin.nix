{
  config,
  lib,
  ...
}: let
  cfg = config.local.services.jellyfin;
  port = 8096;
  dataDir = "/services/jellyfin";

  shortName = config.local.service-registry.jellyfin.shortName;
in {
  options.local.services.jellyfin.enable = lib.mkEnableOption "jellyfin";

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      inherit dataDir;
    };

    local.reverseProxy = {
      enable = true;
      services."${shortName}" = {
        inherit port;
      };
    };
  };
}
