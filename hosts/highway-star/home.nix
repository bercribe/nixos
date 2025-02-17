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
      "[workspace 5 silent] spotify_player"
      "[workspace 6 silent] beeper"
      "[workspace 9 silent] ticktick"
      "[workspace 10 silent] keepassxc"
    ];
  };
  local.swaybar.enableNetwork = false;
}
