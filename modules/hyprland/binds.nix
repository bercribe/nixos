{
  config,
  pkgs,
  lib,
  ...
}: {
  wayland.windowManager.hyprland = {
    settings = {
      # See https://wiki.hyprland.org/Configuring/Keywords/ for more
      "$mainMod" = "SUPER";

      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = let
        slurp = lib.getExe pkgs.slurp;
        grim = lib.getExe pkgs.grim;
        swappy = lib.getExe pkgs.swappy;
        wf-recorder = lib.getExe pkgs.wf-recorder;
        wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
        wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
      in [
        # openers
        "$mainMod, R, exec, $menu"
        "$mainMod, T, exec, $terminal"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, B, exec, $browser"

        # universal copy paste
        "$mainMod, X, sendshortcut, , XF86Cut, activewindow"
        "$mainMod, C, sendshortcut, , XF86Copy, activewindow"
        "$mainMod, V, sendshortcut, , XF86Paste, activewindow"

        # notifications
        "$mainMod, N, exec, ${pkgs.mako}/bin/makoctl dismiss"
        "$mainMod, I, exec, ${pkgs.mako}/bin/makoctl invoke"

        # misc
        "$mainMod, O, movecurrentworkspacetomonitor, +1"
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod, PERIOD, exec, pkill fuzzel || ${lib.getExe pkgs.bemoji} -n"

        # applications
        "$mainMod, M, sendshortcut, CTRL SHIFT, M, class:^discord$" # mute
        "$mainMod, Q, exec, xdg-open obsidian://quickadd?choice=Add%20note"
        "$mainMod, Q, focuswindow, class:^obsidian$"

        # destructive
        "$mainMod SHIFT, D, killactive,"
        "$mainMod SHIFT, K, forcekillactive,"
        "$mainMod SHIFT, L, exec, loginctl lock-session"
        "$mainMod SHIFT, S, exec, systemctl suspend"
        "$mainMod SHIFT, E, exit,"

        # Move focus with mainMod + movement keys
        "$mainMod, H, movefocus, l"
        "$mainMod, L, movefocus, r"
        "$mainMod, K, movefocus, u"
        "$mainMod, J, movefocus, d"
        "$mainMod, Left,  movefocus, l"
        "$mainMod, Right, movefocus, r"
        "$mainMod, Up,    movefocus, u"
        "$mainMod, Down,  movefocus, d"

        # to switch between windows in a floating workspace
        "$mainMod,Tab,cyclenext," # change focus to another window
        "$mainMod,Tab,bringactivetotop," # bring it to the top

        # toggle between monitors
        "$mainMod SHIFT, Tab, focusmonitor, +1"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # Screenshots
        ", Print, exec, pkill slurp || ${grim} -l 0 -g \"$(${slurp})\" - | ${wl-copy}"
        "$mainMod, Print, exec, ${wl-paste} | ${swappy} -f -"
        "$mainMod SHIFT, Print, exec, pkill wf-recorder || pkill slurp || ${wf-recorder} -g \"$(${slurp})\" -f \"$HOME/Videos/$(date).mkv\""
      ];

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # non-consuming
      bindn = [
        ", Alt_L, pass, class:^discord$" # push to talk
      ];

      # use `wev` to find bind names
      # locked
      bindl = [
        # Media keys
        ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ", XF86AudioStop, exec, ${pkgs.playerctl}/bin/playerctl stop"
        ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
        ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"

        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        "$mainMod, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];

      # repeat + locked
      bindel = [
        # Sound control
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"
        "$mainMod, XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ 5%+"
        "$mainMod, XF86AudioLowerVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ 5%-"

        # Screen brightness
        ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl --min-value=1 set 5%-"
        ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%+"
      ];
    };

    extraConfig = ''
      # window management
      bind = $mainMod, W, submap, window
      submap = window

      # misc
      bind = , T, togglesplit, # dwindle
      bind = , P, pseudo, # dwindle
      bind = , F, fullscreen,
      bind = , V, togglefloating,
      bind = , S, movetoworkspace, special:magic

      # groups
      bind = , G, togglegroup,
      bind = , N, changegroupactive,
      bind = SHIFT, G, moveoutofgroup,
      bind = SHIFT, N, changegroupactive, b

      # move rules
      bind = , H, movewindoworgroup, l
      bind = , L, movewindoworgroup, r
      bind = , K, movewindoworgroup, u
      bind = , J, movewindoworgroup, d
      bind = , Left,  movewindoworgroup, l
      bind = , Right, movewindoworgroup, r
      bind = , Up,    movewindoworgroup, u
      bind = , Down,  movewindoworgroup, d

      bind = , 1, movetoworkspace, 1
      bind = , 2, movetoworkspace, 2
      bind = , 3, movetoworkspace, 3
      bind = , 4, movetoworkspace, 4
      bind = , 5, movetoworkspace, 5
      bind = , 6, movetoworkspace, 6
      bind = , 7, movetoworkspace, 7
      bind = , 8, movetoworkspace, 8
      bind = , 9, movetoworkspace, 9
      bind = , 0, movetoworkspace, 10

      # resize rules
      binde = SHIFT, H, resizeactive, -100 0
      binde = SHIFT, L, resizeactive, 100 0
      binde = SHIFT, K, resizeactive, 0 -100
      binde = SHIFT, J, resizeactive, 0 100
      binde = SHIFT, Left,  resizeactive, -100 0
      binde = SHIFT, Right, resizeactive, 100 0
      binde = SHIFT, Up,    resizeactive, 0 -100
      binde = SHIFT, Down,  resizeactive, 0 100

      # escape hatch for switching focus
      bind = ALT, H, movefocus, l
      bind = ALT, L, movefocus, r
      bind = ALT, K, movefocus, u
      bind = ALT, J, movefocus, d
      bind = ALT, Left,   movefocus, l
      bind = ALT, Right,  movefocus, r
      bind = ALT, Up,     movefocus, u
      bind = ALT, Down,   movefocus, d

      # exit
      bind = , Q, submap, reset
      bind = , escape, submap, reset
      submap = reset
    '';
  };
}
