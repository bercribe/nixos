{
  config,
  lib,
  ...
}: {
  wayland.windowManager.hyprland.settings = let
    main = "desc:Dell Inc. AW3423DWF 1YVF2S3";
    top = "desc:Ancor Communications Inc ROG PG279Q ##ASNDQNtIJcHd";
  in {
    monitor = lib.mkForce [
      "${main}, highrr, 0x0, 1"
      "${top}, 2560x1440@100, 440x-1440, 1"
    ];
    cursor = {
      no_hardware_cursors = true;
    };
    workspace = [
      "1,monitor:${main},default:true"
      "2,monitor:${main}"
      "3,monitor:${main}"
      "4,monitor:${main}"
      "5,monitor:${main}"
      "6,monitor:${top},default:true"
      "7,monitor:${top}"
      "8,monitor:${top}"
      "9,monitor:${top}"
      "10,monitor:${top}"
    ];
    exec-once = [
      "[workspace 1 silent] alacritty"
      "[workspace 6 silent] firefox"
      "[workspace 6 silent] obsidian"
      "[workspace 7 silent] beeper"
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
  };
}
