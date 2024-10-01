{
  pkgs,
  config,
  home-manager,
  ...
}: {
  programs.hyprland.enable = true;

  # display manager
  services.xserver.displayManager.lightdm.enable = false;
  environment.loginShellInit = "[ \"$(tty)\" = \"/dev/tty1\" ] && hyprland";
  # services.displayManager.sddm = {
  #   enable = true;
  #   wayland.enable = true;
  #   theme = "${import ./sddm-theme.nix {inherit pkgs config;}}";
  # };

  environment.systemPackages = with pkgs; [
    kitty # terminal
    wofi # app launcher
    # status bar
    (waybar.overrideAttrs
      (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
      }))
    thunar # file browser
    mako # notifications
    hyprpaper # wallpapers
    brightnessctl # screen brightess
    # screenshots
    grim
    slurp
    wl-clipboard # clipboard
    networkmanagerapplet # wifi widget
    # libsForQt5.qt5.qtgraphicaleffects # for sddm theme
  ];

  # enabling this causes flickering in electron apps with nvidia hardware
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # icons for waybar
  fonts.packages = with pkgs; [nerdfonts font-awesome];

  # without this, swaylock refuses to accept the correct password
  security.pam.services.swaylock = {};

  # screen sharing
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      # allow apps to open dbus FileChooser
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  home-manager.users.mawz = import ./config.nix;
}
