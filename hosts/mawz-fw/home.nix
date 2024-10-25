{
  config,
  lib,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "[workspace 1 silent] alacritty"
      "[workspace 2 silent] firefox"
      "[workspace 3 silent] obsidian"
      "[workspace 9 silent] ticktick"
      "[workspace 10 silent] keepassxc"
    ];
  };
}
