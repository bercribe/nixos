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
      "[workspace 5 silent] ncspot"
      "[workspace 6 silent] beeper"
      "[workspace 9 silent] ticktick"
      "[workspace 10 silent] keepassxc"
    ];
  };
  local.swaybar.enableNetwork = false;
}
