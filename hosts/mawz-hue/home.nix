{
  config,
  lib,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    monitor = lib.mkForce [
      "desc:Ancor Communications Inc ROG PG279Q ##ASNDQNtIJcHd,2560x1440@144,0x0,1"
      "desc:Ancor Communications Inc ROG PG279Q ##ASNpS7wVCX7d,2560x1440@144,2560x-900,1,transform,1"
    ];
    cursor = {
      no_hardware_cursors = true;
    };
  };
}
