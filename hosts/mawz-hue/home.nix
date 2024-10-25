{
  config,
  lib,
  ...
}: {
  wayland.windowManager.hyprland.settings = let
    left = "desc:Ancor Communications Inc ROG PG279Q ##ASNDQNtIJcHd";
    right = "desc:Ancor Communications Inc ROG PG279Q ##ASNpS7wVCX7d";
  in {
    monitor = lib.mkForce [
      "${left},2560x1440@144,0x0,1"
      "${right},2560x1440@144,2560x-900,1,transform,1"
    ];
    cursor = {
      no_hardware_cursors = true;
    };
    workspace = [
      "1,monitor:${left},default:true"
      "2,monitor:${left}"
      "3,monitor:${left}"
      "4,monitor:${left}"
      "5,monitor:${left}"
      "6,monitor:${right},default:true"
      "7,monitor:${right}"
      "8,monitor:${right}"
      "9:monitor:${right}"
      "10,monitor:${right}"
    ];
    exec-once = [
      "[workspace 1 silent] alacritty"
      "[workspace 6 silent] firefox"
      "[workspace 6 silent] obsidian"
      "[workspace 10 silent] ticktick"
      "[workspace 10 silent] keepassxc"
    ];
  };

  programs.waybar.settings.mainBar."hyprland/workspaces"."format-icons" = lib.mkForce {
    "1" = "";
    "2" = "";
    "6" = "";
    "7" = "";
    "10" = "";
    "urgent" = "";
    "active" = "";
    "default" = "";
  };

  programs.lf.keybindings = {
    gr = "cd /zrust";
    gs = "cd /zsolid";
    gw = "cd /mnt/windows";
  };
}
