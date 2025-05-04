{
  config,
  self,
  lib,
  ...
}: let
  cfg = config.local.services.syncthing-headless;

  shortName = config.local.service-registry.syncthing-headless.shortName;
in {
  imports = [
    ./default.nix
    (self + /modules/cron/syncthing-healthchecks.nix)
  ];

  options.local.services.syncthing-headless.enable = lib.mkEnableOption "syncthing-headless";

  config = lib.mkIf cfg.enable {
    local.services.syncthing.enable = true;
    local.cron.syncthing-healthchecks.enable = true;

    local.reverseProxy = {
      enable = true;
      services."${shortName}" = {
        port = 8384;
        httpsBackend = true;
      };
    };
  };
}
