{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.local;
in {
  imports = [./binds.nix];

  options.local.waybar = {
    enableNetwork = lib.mkEnableOption "network";
  };

  config = {
    local.waybar.enableNetwork = lib.mkDefault true;

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false; # conflicts with uwsm
      settings = {
        # See https://wiki.hyprland.org/Configuring/Monitors/
        monitor = ",preferred,auto,auto";

        # See https://wiki.hyprland.org/Configuring/Keywords/ for more

        # Execute your favorite apps at launch
        exec-once = [
          "${pkgs.waybar}/bin/waybar" # status bar
          "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator" # network picker
          "${pkgs.blueman}/bin/blueman-applet" # bluetooth
          "${pkgs.udiskie}/bin/udiskie" # USB automount frontend
          "fcitx5 -d" # keyboard input languages. needs to be run from path to load config properly
          "${pkgs.syncthingtray}/bin/syncthingtray --wait" # tray icon for syncthing
        ];

        # Source a file (multi-file configs)
        # source = ~/.config/hypr/myColors.conf

        # Set programs that you use
        "$terminal" = "$TERMINAL";
        "$fileManager" = "$TERMINAL -e yazi";
        "$browser" = "$BROWSER";
        # Open fuzzel on first press, closes it on second
        "$menu" = "pkill fuzzel || ${lib.getExe pkgs.fuzzel}";

        # Some default env vars.
        # env = [
        #   "QT_QPA_PLATFORMTHEME,qt5ct" # change to qt6ct if you have that
        # ];

        # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
        input = {
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
          kb_options = "";
          kb_rules = "";

          numlock_by_default = true;

          follow_mouse = 1;

          touchpad = {
            natural_scroll = "yes";
            scroll_factor = 0.3;
          };

          sensitivity = 0; # -1.0 to 1.0, 0 means no modification.
          accel_profile = "flat";
        };

        general = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          # "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          # "col.inactive_border" = "rgba(595959aa)";

          layout = "dwindle";

          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = false;
        };

        decoration = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          rounding = 10;

          blur = {
            enabled = true;
            size = 3;
            passes = 1;
          };

          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            # color = "rgba(1a1a1aee)";
          };
        };

        animations = {
          enabled = "yes";

          # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        dwindle = {
          # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
          pseudotile = "yes"; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = "yes"; # you probably want this
        };

        master = {
          # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
          new_status = "master";
        };

        gestures = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          workspace_swipe = true;
        };

        misc = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          force_default_wallpaper = 0; # Set to 0 or 1 to disable the anime mascot wallpapers
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
        };

        # Example per-device config
        # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
        device = {
          name = "logitech-m350-1";
          sensitivity = -1;
        };

        # Example windowrule v1
        # windowrule = float, ^(kitty)$
        # Example windowrule v2
        # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
        windowrulev2 = "suppressevent maximize, class:.*"; # You'll probably like this.
      };
    };

    services.hyprpaper = {
      enable = true;
      # configured with stylix
      # settings = {
      #   preload = "${config.stylix.image}";
      #   wallpaper = ",${config.stylix.image}";
      # };
    };

    programs.hyprlock = {
      # encountered some issues resuming from suspend with hyprlock enabled
      # enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          hide_cursor = true;
          no_fade_in = false;
        };

        # set by stylix
        # background = [
        #   {
        #     path = "${config.stylix.image}";
        #     blur_passes = 3;
        #     blur_size = 8;
        #   }
        # ];
        # input-field = [
        #   {
        #     size = "200, 50";
        #     position = "0, -80";
        #     monitor = "";
        #     dots_center = true;
        #     fade_on_empty = false;
        #     font_color = "rgb(202, 211, 245)";
        #     inner_color = "rgb(91, 96, 120)";
        #     outer_color = "rgb(24, 25, 38)";
        #     outline_thickness = 5;
        #     placeholder_text = "Password...";
        #     shadow_passes = 2;
        #   }
        # ];
      };
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "swaylock";
          before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
          after_sleep_cmd = "sleep 2; hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
        };
        listener = [
          {
            timeout = 150; # 2.5min.
            on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
            on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r"; # monitor backlight restore.
          }
          # turn off keyboard backlight, comment out this section if you dont have a keyboard backlight.
          # {
          #   timeout = 150; # 2.5min.
          #   on-timeout = ${pkgs.brightnessctl}/bin/brightnessctl -sd rgb:kbd_backlight set 0; # turn off keyboard backlight.
          #   on-resume = ${pkgs.brightnessctl}/bin/brightnessctl -rd rgb:kbd_backlight; # turn on keyboard backlight.
          # }
          {
            timeout = 300; # 5min
            on-timeout = "loginctl lock-session"; # lock screen when timeout has passed
          }
          {
            timeout = 330; # 5.5min
            on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
            on-resume = "sleep 2; hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
          }
          {
            timeout = 1800; # 30min
            on-timeout = "systemctl suspend"; # suspend pc
          }
        ];
      };
    };

    programs.waybar = {
      enable = true;
      # style = ./waybar-style.css;
      settings = {
        mainBar = {
          "layer" = "top"; # Waybar at top layer
          # "position": "bottom", # Waybar position (top|bottom|left|right)
          "height" = 30; # Waybar height (to be removed for auto height)
          # "width": 1280, # Waybar width
          "spacing" = 4; # Gaps between modules (4px)
          # Choose the order of the modules
          "modules-left" = [
            "hyprland/workspaces"
            "hyprland/submap"
            "sway/scratchpad"
            "custom/media"
          ];
          "modules-center" = [
            "hyprland/window"
          ];
          "modules-right" =
            [
              "mpd"
              "idle_inhibitor"
              "pulseaudio"
            ]
            ++ (
              if cfg.waybar.enableNetwork
              then [
                "network"
              ]
              else []
            )
            ++ [
              "power-profiles-daemon"
              "cpu"
              "memory"
              "temperature"
              "backlight"
              "keyboard-state"
              "sway/language"
              "battery"
              "battery#bat2"
              "clock"
              "tray"
            ];
          # Modules configuration
          "hyprland/workspaces" = {
            "disable-scroll" = true;
            "all-outputs" = true;
            "warp-on-scroll" = false;
            "show-special" = true;
            "format" = "{name}: {icon}";
            "format-icons" = {
              "1" = "";
              "2" = "";
              "6" = "";
              "7" = "";
              "8" = "";
              "9" = "";
              "10" = "";
              "urgent" = "";
              "active" = "";
              "default" = "";
            };
          };
          "keyboard-state" = {
            "numlock" = true;
            "capslock" = true;
            "format" = "{name} {icon}";
            "format-icons" = {
              "locked" = "";
              "unlocked" = "";
            };
          };
          "hyprland/submap" = {
            "format" = "<span style=\"italic\">{}</span>";
          };
          "sway/scratchpad" = {
            "format" = "{icon} {count}";
            "show-empty" = false;
            "format-icons" = ["" ""];
            "tooltip" = true;
            "tooltip-format" = "{app}: {title}";
          };
          "mpd" = {
            "format" = "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ";
            "format-disconnected" = "Disconnected ";
            "format-stopped" = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
            "unknown-tag" = "N/A";
            "interval" = 5;
            "consume-icons" = {
              "on" = " ";
            };
            "random-icons" = {
              "off" = "<span color=\"#f53c3c\"></span> ";
              "on" = " ";
            };
            "repeat-icons" = {
              "on" = " ";
            };
            "single-icons" = {
              "on" = "1 ";
            };
            "state-icons" = {
              "paused" = "";
              "playing" = "";
            };
            "tooltip-format" = "MPD (connected)";
            "tooltip-format-disconnected" = "MPD (disconnected)";
          };
          "idle_inhibitor" = {
            "format" = "{icon}";
            "format-icons" = {
              "activated" = " ";
              "deactivated" = " ";
            };
          };
          "tray" = {
            # "icon-size": 21,
            "spacing" = 10;
          };
          "clock" = {
            # "timezone": "America/New_York",
            "format" = "{:%m-%d %H:%M}";
            "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            "format-alt" = "{:%Y-%m-%d}";
          };
          "cpu" = {
            "format" = "{usage}% ";
            "tooltip" = false;
          };
          "memory" = {
            "format" = "{}% ";
          };
          "temperature" = {
            # "thermal-zone": 2,
            # "hwmon-path": "/sys/class/hwmon/hwmon2/temp1_input",
            "critical-threshold" = 80;
            # "format-critical": "{temperatureC}°C {icon}",
            "format" = "{temperatureC}°C {icon}";
            "format-icons" = ["" "" ""];
          };
          "backlight" = {
            # "device": "acpi_video1",
            "format" = "{percent}% {icon}";
            "format-icons" = ["🌑" "🌘" "🌗" "🌖" "🌕"];
          };
          "battery" = {
            "states" = {
              # "good": 95,
              "warning" = 30;
              "critical" = 15;
            };
            "format" = "{capacity}% {icon}";
            "format-full" = "{capacity}% {icon}";
            "format-charging" = "{capacity}% ";
            "format-plugged" = "{capacity}% ";
            "format-alt" = "{time} {icon}";
            # "format-good": "", # An empty format will hide the module
            # "format-full": "",
            "format-icons" = [" " " " " " " " " "];
          };
          "battery#bat2" = {
            "bat" = "BAT2";
          };
          "power-profiles-daemon" = {
            "format" = "{icon}";
            "tooltip-format" = "Power profile: {profile}\nDriver: {driver}";
            "tooltip" = true;
            "format-icons" = {
              "default" = "";
              "performance" = "";
              "balanced" = "";
              "power-saver" = "";
            };
          };
          "network" = {
            # "interface": "wlp2*", # (Optional) To force the use of this interface
            "format-wifi" = "{essid} ({signalStrength}%)  ";
            "format-ethernet" = "{ipaddr}/{cidr}  ";
            "tooltip-format" = "{ifname} via {gwaddr}  ";
            "format-linked" = "{ifname} (No IP)  ";
            "format-disconnected" = "Disconnected ⚠ ";
            "format-alt" = "{ifname}: {ipaddr}/{cidr}";
          };
          "pulseaudio" = {
            # "scroll-step": 1, # %, can be a float
            "format" = "{volume}% {icon} {format_source}";
            "format-bluetooth" = "{volume}% {icon} {format_source}";
            "format-bluetooth-muted" = "  {icon} {format_source}";
            "format-muted" = "  {format_source}";
            "format-source" = "{volume}% ";
            "format-source-muted" = "";
            "format-icons" = {
              "headphone" = "";
              "hands-free" = "";
              "headset" = "";
              "phone" = "";
              "portable" = "";
              "car" = "";
              "default" = [" " " " " "];
            };
            "on-click" = "pavucontrol";
          };
          "custom/media" = {
            "format" = "{icon} {}";
            "return-type" = "json";
            "max-length" = 40;
            "format-icons" = {
              "spotify" = "";
              "ncspot" = "";
              "default" = "🎜";
            };
            "escape" = true;
            "exec" = "${pkgs.waybar}/bin/waybar-mediaplayer.py 2> /dev/null"; # Script in resources folder
            # "exec": "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null" # Filter player based on name
          };
        };
      };
    };

    # needed for stylix theming
    programs.fuzzel.enable = true;
    programs.swaylock.enable = true;
    services.mako.enable = true;
  };
}
