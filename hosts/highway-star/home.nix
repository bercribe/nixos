{
  config,
  lib,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "[workspace 1 silent] $TERMINAL"
      "[workspace 2 silent] firefox"
      "[workspace 3 silent] obsidian"
      "[workspace 5 silent] $TERMINAL -e ncspot"
      "[workspace 6 silent] beeper"
      "[workspace 9 silent] ticktick"
      "[workspace 10 silent] keepassxc"
    ];
  };
  local.waybar.enableNetwork = false;
}
