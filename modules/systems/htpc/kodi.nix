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

    displayManager = {
      autoLogin = {
        enable = true;
        user = "kodi";
      };
      lightdm.greeter.enable = false;
    };
  };

  # Define a user account
  users.extraUsers.kodi.isNormalUser = true;
}
