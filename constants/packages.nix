{
  pkgs,
  lib,
  ...
}: let
  core = with pkgs; [
    dig # dns debug
    fd # better find
    fzf # fuzzy find
    git # version control
    hexyl # hex viewer
    jq # json formatter
    lazygit # git tui
    python3 # scripting
    ripgrep # file content search
    tcpdump # network sniffer
    tmux # terminal multiplexer
    tree # directory tree
    unzip # zip extractor
    wget # network util
    yazi # terminal file manager
    zip # zip compressor
  ];

  scripts = with pkgs.scripts; [
    gtgh
    st
    tsl
    twl
  ];
in {
  options.local.constants.packages = with lib;
  with types; {
    core = mkOption {
      type = listOf package;
      description = "Core packages";
    };
    scripts = mkOption {
      type = listOf package;
      description = "User defined scripts";
    };
    system = mkOption {
      type = listOf package;
      description = "Installed as system packages on all systems";
    };
    user = mkOption {
      type = listOf package;
      description = "Installed as user packages on all systems";
    };
    system-desktop = mkOption {
      type = listOf package;
      description = "Installed as system packages on GUI systems";
    };
    user-desktop = mkOption {
      type = listOf package;
      description = "Installed as user packages on GUI systems";
    };
  };

  config.local.constants.packages = with pkgs; {
    inherit core scripts;

    system =
      [
        lzop # compression with syncoid
        mbuffer # buffering with syncoid
        neovim # text editor
        rclone # network file mounts
        usbutils # lsusb
      ]
      ++ core ++ scripts;

    system-desktop = [
      libnotify # desktop notification util
      wl-clipboard # clipboard
    ];

    user = [
      alejandra # nix formatter
      bat # better cat
      bluetui # bluetooth device tui
      btop # performance visualizer
      cht-sh # cheat sheet
      delta # better diff
      devenv # nix based developer environments
      difftastic # syntax aware diff
      exiftool # image metadata
      eza # better ls
      ffmpeg # video utilities
      gdu # go disk analyzer
      gh # github cli
      hledger # ledger accounting tool
      hledger-ui # hledger tui
      isd # systemd TUI
      jujutsu # version control
      lf # list files
      mosh # mobile shell
      mtr # ping + traceroute
      neofetch # system info
      nh # nix helper
      nix-inspect # nix env tui explorer
      restic # backup tool
      sops # secrets management
      wikiman # CLI docs
      wiper # disk cleanup tool
      wireguard-tools # wireguard debug
      wol # wake on lan
    ];

    user-desktop = [
      # GUI
      anki # SRS app
      beeper # universal chat
      bs-manager # mod manager for beat saber
      chromium # browser
      czkawka # deduping util
      discord # voice chat
      firefox # browser
      foot # terminal
      gale # thunderstore mod manager
      ghostty # terminal
      godot_4 # game engine
      handbrake # video transcoding
      imagemagick # image viewer
      imv # image viewer
      inkscape # svg editor
      keepassxc # password manager
      libation # audible audiobook manager
      libreoffice # office tools
      localsend # file sending utility
      makemkv # blu-ray ripper
      mangohud # fps overlay
      mpv # video player
      obs-studio # screen recording
      obsidian # PKM tool
      pavucontrol # sound control
      pureref # reference image viewer
      shotwell # photo editor
      thunar # file browser
      wineWowPackages.waylandFull # windows game emulator
      wireshark # network analyzer
      xivlauncher # ffxiv
      zathura # pdf viewer
      zoom-us # video conferencing
      # CLI
      cava # audio visualizer
      ffsubsync # sync subtitles with video
      gtypist # typing tutor
      handlr-regex # better xdg-open
      ncspot # spotify TUI
      qmk # keyboard firmware
      spotify-player # spotify TUI
      typst # document editor
      wev # shows keyboard inputs
      yt-dlp # youtube downloader
      zbar # QR code utils
    ];
  };
}
