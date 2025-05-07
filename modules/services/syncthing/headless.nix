{
  config,
  self,
  lib,
  ...
}: let
  cfg = config.local.services.syncthing-headless;
in {
  imports = [
    ./base.nix
    (self + /modules/cron/syncthing-healthchecks.nix)
  ];

  options.local.services.syncthing-headless.enable = lib.mkEnableOption "syncthing-headless";

  config = lib.mkIf cfg.enable {
    local.services.syncthing-base.enable = true;
    local.cron.syncthing-healthchecks.enable = true;

    local.reverseProxy = {
      enable = true;
      services.syncthing-headless = {
        port = 8384;
        httpsBackend = true;
      };
    };
  };
}
