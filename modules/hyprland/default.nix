{
  pkgs,
  config,
  lib,
  home-manager,
  ...
}: {
  programs.hyprland.enable = true;

  # Display manager
  services.xserver.displayManager.lightdm.enable = false;
  environment.loginShellInit = "[ \"$(tty)\" = \"/dev/tty1\" ] && Hyprland";

  services.displayManager.sddm = {
    enable = false;
    wayland.enable = true;
    theme = "${import ./sddm-theme.nix {inherit pkgs config;}}";
  };

  # User env
  environment.systemPackages = with pkgs; [
    thunar # file browser
    wl-clipboard # clipboard
    # libsForQt5.qt5.qtgraphicaleffects # for sddm theme
  ];

  # enabling this causes flickering in electron apps with nvidia hardware
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # icons for waybar
  fonts.packages = let
    nerdfonts = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
  in
    nerdfonts ++ [pkgs.font-awesome];

  home-manager.users.mawz = import ./config.nix;

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
}
