{pkgs, ...}: {
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

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
}
