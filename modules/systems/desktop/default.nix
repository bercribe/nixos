{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../hyprland # Tiling window manager
    ../network/mount.nix
    ../bluray.nix
    ../../sops.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.grub.configurationLimit = 5;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Fix command-not-found functionality for flakes
  programs.command-not-found.enable = false;
  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
  };

  # Enable Japanese and Chinese keyboards
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-chinese-addons
      ];
      settings = {
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            # Default Input Method
            "DefaultIM" = "keyboard-us";
          };
          "Groups/0/Items/0" = {
            Name = "keyboard-us";
            Layout = null;
          };
          "Groups/0/Items/1" = {
            Name = "mozc";
            Layout = null;
          };
          "Groups/0/Items/2" = {
            Name = "pinyin";
            Layout = null;
          };
          GroupOrder = {
            "0" = "Default";
          };
        };
        globalOptions = {
          "Hotkey" = {
            # Enumerate when press trigger key repeatedly
            EnumerateWithTriggerKeys = "True";
            # Enumerate Input Method Forward
            EnumerateForwardKeys = "";
            # Enumerate Input Method Backward
            EnumerateBackwardKeys = "";
            # Skip first input method while enumerating
            EnumerateSkipFirst = "False";
          };
          "Hotkey/TriggerKeys" = {
            "0" = "Super+space";
            "1" = "Zenkaku_Hankaku";
            "2" = "Hangul";
          };
          "Hotkey/AltTriggerKeys" = {
            "0" = "Shift_L";
          };
          "Hotkey/EnumerateGroupForwardKeys" = {
            "0" = "Super+space";
          };
          "Hotkey/EnumerateGroupBackwardKeys" = {
            "0" = "Shift+Super+space";
          };
          "Hotkey/ActivateKeys" = {
            "0" = "Hangul_Hanja";
          };
          "Hotkey/DeactivateKeys" = {
            "0" = "Hangul_Romaja";
          };
          "Hotkey/PrevPage" = {
            "0" = "Up";
          };
          "Hotkey/NextPage" = {
            "0" = "Down";
          };
          "Hotkey/PrevCandidate" = {
            "0" = "Shift+Tab";
          };
          "Hotkey/NextCandidate" = {
            "0" = "Tab";
          };
          "Hotkey/TogglePreedit" = {
            "0" = "Control+Alt+P";
          };
          "Behavior" = {
            # Active By Default
            ActiveByDefault = "False";
            # Reset state on Focus In
            resetStateWhenFocusIn = "No";
            # Share Input State
            ShareInputState = "No";
            # Show preedit in application
            PreeditEnabledByDefault = "True";
            # Show Input Method Information when switch input method
            ShowInputMethodInformation = "True";
            # Show Input Method Information when changing focus
            showInputMethodInformationWhenFocusIn = "False";
            # Show compact input method information
            CompactInputMethodInformation = "True";
            # Show first input method information
            ShowFirstInputMethodInformation = "True";
            # Default page size
            DefaultPageSize = 5;
            # Override Xkb Option
            OverrideXkbOption = "False";
            # Custom Xkb Option
            CustomXkbOption = "";
            # Force Enabled Addons
            EnabledAddons = "";
            # Force Disabled Addons
            DisabledAddons = "";
            # Preload input method to be used by default
            PreloadInputMethod = "True";
            # Allow input method in the password field
            AllowInputMethodForPassword = "False";
            # Show preedit text when typing password
            ShowPreeditForPassword = "False";
            # Interval of saving user data in minutes
            AutoSavePeriod = 30;
          };
        };
      };
    };
  };

  # Enable Japanese and Chinese fonts
  fonts.packages = with pkgs; [dejavu_fonts ipafont];
  fonts.fontconfig.defaultFonts = {
    monospace = [
      "DejaVu Sans Mono"
      "IPAGothic"
    ];
    sansSerif = [
      "DejaVu Sans"
      "IPAPGothic"
    ];
    serif = [
      "DejaVu Serif"
      "IPAPMincho"
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mawz = {
    extraGroups = ["wireshark"];
    packages = with pkgs; [
      firefox
      keepassxc
      obsidian
      vscode
      alacritty
      discord
      spotube
      libreoffice
      typst
      typst-live
      wireshark
      godot_4
      qimgv
      mpv
      imagemagick
      exiftool
      shotwell # photo editor
      czkawka # deduping util
      makemkv # blu-ray ripper
      handbrake # video transcoding
      ffsubsync # sync subtitles with video
      #  thunderbird
      python3
      # cli extras
      ripgrep
      lf
      neofetch
      btop
      cava
    ];
  };

  # Required for obsidian
  nixpkgs.config.permittedInsecurePackages = ["electron-25.9.0"];

  programs.wireshark.enable = true;

  programs.firefox = {
    enable = true;
    policies = {
      DisplayBookmarksToolbar = "always";
      ExtensionSettings = {
        "firefox@betterttv.net" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/betterttv/latest.xpi";
          "default_area" = "menupanel";
        };
        "addon@darkreader.org" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          "default_area" = "navbar";
        };
        "enhancerforyoutube@maximerf.addons.mozilla.org" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/enhancer-for-youtube/latest.xpi";
          "default_area" = "menupanel";
        };
        "jid1-KKzOGWgsW3Ao4Q@jetpack" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/i-dont-care-about-cookies/latest.xpi";
          "default_area" = "menupanel";
        };
        "search@kagi.com" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/kagi-search-for-firefox/latest.xpi";
          "default_area" = "menupanel";
        };
        "keepassxc-browser@keepassxc.org" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
          "default_area" = "menupanel";
        };
        "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/old-reddit-redirect/latest.xpi";
          "default_area" = "menupanel";
        };
        "jid0-adyhmvsP91nUO8pRv0Mn2VKeB84@jetpack" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/raindropio/latest.xpi";
          "default_area" = "navbar";
        };
        "jid1-xUfzOsOFlzSOXg@jetpack" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/reddit-enhancement-suite/latest.xpi";
          "default_area" = "menupanel";
        };
        "sponsorBlocker@ajay.app" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          "default_area" = "menupanel";
        };
        "treestyletab@piro.sakura.ne.jp" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/tree-style-tab/latest.xpi";
          "default_area" = "menupanel";
        };
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
          "default_area" = "navbar";
        };
        "uBlock0@raymondhill.net" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          "default_area" = "navbar";
        };
      };
    };
  };

  # to use these, add launch options to game in steam:
  # `gamemoderun %command%` - improves performance
  # `mangohud %command%` - fps monitor
  # `gamescope %command%` - helps with resoltion issues sometimes
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    alejandra
    libnotify
    fzf
    unzip
    syncthing
    restic
    sops
    pavucontrol
    mangohud
  ];

  # Set defaults
  environment.variables.EDITOR = "vim";
  environment.variables.BROWSER = "firefox";
  environment.variables.TERMINAL = "alacritty";

  # Home manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # fixes issue where login can fail due to home-manager
    backupFileExtension = "backup";
    users.mawz = import ./home.nix;
  };

  sops.secrets = {
    restic-repo = {
      owner = "mawz";
    };
    "mawz-nas/upsd" = {};
    network-manager = {};
  };

  # Theme settings
  stylix = {
    enable = true;
    image = ./wallpaper.jpg;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest-dark-hard.yaml";
  };

  # List services that you want to enable:

  # Manually created and repermissioned directories
  systemd.tmpfiles.rules = [
    "d /backups 0755 mawz users -"
    "d /backups/restic-repo 0755 mawz users -"
  ];

  # Printer
  services.printing.enable = true;
  # Auto network discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # USB drive automount
  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };

  # Restic file system backups
  services.restic.backups = {
    localbackup = {
      user = "mawz";
      exclude = [
        "/home/*/.cache"
      ];
      initialize = true;
      passwordFile = config.sops.secrets.restic-repo.path;
      paths = [
        "/home"
      ];
      repository = "/backups/restic-repo";
    };
  };

  # Syncthing folders. Access UI at: http://127.0.0.1:8384/
  services.syncthing = {
    enable = true;
    user = "mawz";
    dataDir = "/home/mawz/Documents"; # Default folder for new synced folders
    configDir = "/home/mawz/Documents/.config/syncthing"; # Folder for Syncthing's settings and keys
    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI
    settings = {
      devices = {
        "mawz-nas" = {id = "XX5DKCN-4OTCVAB-2QWFVBN-NVIK24H-AENGONB-FQ67OPV-GITYMJY-55S6AAV";};
        "mawz-hue" = {id = "D2VC45J-2GRDWF4-NAIWZA7-VTRHVCR-FDEZNNG-2P5ERHE-CLPZ6UK-JI3NEQ7";};
        "mawz-hue-win" = {id = "UCHJJO7-WXOENUZ-SBOV5NO-LSRAGOJ-IWGNSCY-SETUCQF-5PZTPLZ-VXWYFQG";};
        "mawz-fw" = {id = "EASFCDW-AI3FKGE-RECE37P-ZUN7WOZ-4YWFU2K-CLTJ2GG-YIBZJCW-D3EBNQN";};
        "mawz-galaxy" = {id = "Z5BAWSH-SKUWWP7-AIPUJIT-FNB4E3U-4LDOCVV-XGZOBHO-VJ26EAB-XNHEFAF";};
      };
      folders = {
        personal-cloud = {
          enable = lib.mkDefault false;
          path = lib.mkDefault "/home/mawz/personal-cloud";
          devices = ["mawz-nas" "mawz-hue" "mawz-hue-win" "mawz-fw" "mawz-galaxy"];
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600";
              maxAge = "31536000";
            };
          };
        };
        projects = {
          enable = lib.mkDefault false;
          path = lib.mkDefault "/home/mawz/projects";
          devices = ["mawz-nas" "mawz-hue" "mawz-hue-win" "mawz-fw"];
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600";
              maxAge = "2592000";
            };
          };
        };
        libraries = {
          enable = lib.mkDefault false;
          path = lib.mkDefault "/home/mawz/libraries";
          devices = ["mawz-nas" "mawz-hue" "mawz-hue-win"];
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600";
              maxAge = "2592000";
            };
          };
        };
      };
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
}
