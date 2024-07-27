{
  config,
  lib,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    monitor = lib.mkForce [
      "desc:Ancor Communications Inc ROG PG279Q ##ASNpS7wVCX7d,preferred,auto,1,transform,1"
      ",preferred,auto,1"
    ];
  };
}
