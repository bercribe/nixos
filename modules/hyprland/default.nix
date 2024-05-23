{pkgs, ...}: {
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
    kitty # terminal
    wofi # app launcher
    # status bar
    (waybar.overrideAttrs
      (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
      }))
    dolphin # file browser
    # notifications
    mako
    libnotify
    hyprpaper # wallpapers
    # screen brightess
    brightnessctl
    # screenshots
    grim
    slurp
    wl-clipboard
    # lock screen
    hyprlock
  ];
  # icons for waybar
  fonts.packages = with pkgs; [font-awesome];
  # screen sharing
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-hyprland];
  };
}
