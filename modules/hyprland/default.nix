{pkgs, ...}: {
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
    kitty # terminal
    wofi # app launcher
    waybar # status bar
    dolphin # file browser
    # notifications
    mako
    libnotify
    hyprpaper # wallpapers
    # screen brightess
    brightnessctl
  ];
  # icons for waybar
  fonts.packages = with pkgs; [font-awesome];
}
