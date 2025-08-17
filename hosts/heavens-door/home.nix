{
  self,
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

  wayland.windowManager.hyprland.settings = let
    main = "desc:Dell Inc. AW3423DWF 1YVF2S3";
    top = "desc:Ancor Communications Inc ROG PG279Q K5LMQS058625";
  in {
    monitor = lib.mkForce [
      "${main}, highrr, 0x0, 1"
      "${top}, preferred, 440x-1440, 1"
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
      "[workspace 1 silent] $TERMINAL"
      "[workspace 6 silent] firefox"
      "[workspace 6 silent] obsidian"
      "[workspace 7 silent] beeper"
      "[workspace 7 silent] $TERMINAL -e ncspot"
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

  local.yazi.keybinds = {
    goto-zsolid = {
      bind = ["g" "z" "s"];
      command = "cd /zsolid";
    };
    goto-zrust = {
      bind = ["g" "z" "r"];
      command = "cd /zrust";
    };
    goto-libraries = {
      bind = ["g" "s" "l"];
      command = "cd /zsolid/syncthing/libraries";
    };
  };

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
