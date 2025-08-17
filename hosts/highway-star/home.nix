{
  config,
  lib,
  ...
}: {
  imports = let
    rootDir = ../..;
  in [
    (rootDir + /modules/systems/home)
    (rootDir + /modules/systems/desktop/home.nix)
    (rootDir + /modules/hyprland/home.nix)
  ];

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "[workspace 1 silent] $TERMINAL"
      "[workspace 2 silent] firefox"
      "[workspace 3 silent] obsidian"
      "[workspace 5 silent] $TERMINAL -e ncspot"
      "[workspace 6 silent] beeper"
      "[workspace 10 silent] keepassxc"
    ];
  };
  local.waybar.enableNetwork = false;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";
}
