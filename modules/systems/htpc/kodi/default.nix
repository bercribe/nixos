{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.local.services.kodi;
in {
  options.local.services.kodi.enable = lib.mkEnableOption "kodi";

  config = {
    services.xserver = {
      enable = true;

      desktopManager = {
        kodi = {
          enable = true;
          package = pkgs.kodi.withPackages (pkgs:
            with pkgs; [
              invidious # youtube
              jellycon # jellyfin
              netflix # netflix
              sendtokodi # plays video url
              sponsorblock # youtube addon
              youtube # youtube
            ]);
        };
      };

      displayManager.lightdm.greeter.enable = false;
    };

    services.displayManager.autoLogin = {
      enable = true;
      user = "kodi";
    };

    # Define a user account
    users.extraUsers.kodi = {
      isNormalUser = true;
      home = "/services/kodi";
    };

    # remote
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    local.reverseProxy = lib.mkIf cfg.enable {
      enable = true;
      services.kodi = {
        port = 8080;
      };
    };
  };
}
