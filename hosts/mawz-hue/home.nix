{
  config,
  lib,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    monitor = lib.mkForce [
      "desc:Ancor Communications Inc ROG PG279Q ##ASNDQNtIJcHd,preferred,0x0,1"
      "desc:Ancor Communications Inc ROG PG279Q ##ASNpS7wVCX7d,preferred,2560x-900,1,transform,1"
    ];
  };
}
