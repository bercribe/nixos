{
  pkgs,
  config,
  ...
}: {
  programs.hyprland.enable = true;

  # display manager - lightdm doesn't work reliably with hyprland
  services.xserver = {
    enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "${import ./sddm-theme.nix {inherit pkgs config;}}";
    };
  };

  environment.systemPackages = with pkgs; [
    kitty # terminal
    wofi # app launcher
    # status bar
    (waybar.overrideAttrs
      (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
      }))
    cinnamon.nemo # file browser
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
    # wifi widget
    networkmanagerapplet
    # for sddm theme
    libsForQt5.qt5.qtgraphicaleffects
  ];

  # icons for waybar
  fonts.packages = with pkgs; [font-awesome];

  # without this, swaylock refuses to accept the correct password
  security.pam.services.swaylock = {};

  # screen sharing
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-hyprland];
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
}
