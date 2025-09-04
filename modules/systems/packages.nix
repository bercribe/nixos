{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.local.packages;
in {
  options.local.packages = with lib;
  with types; {
    headless = mkOption {
      type = bool;
      description = "False to include desktop based packages";
    };
  };

  config = with pkgs; {
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = let
      base = [
        dig # dns debug
        fd # better find
        fzf # fuzzy find
        git # version control
        hexyl # hex viewer
        jq # json formatter
        lzop # compression with syncoid
        mbuffer # buffering with syncoid
        neovim # text editor
        python3 # scripting
        rclone # network file mounts
        ripgrep # file content search
        tcpdump # network sniffer
        tmux # terminal multiplexer
        tree # directory tree
        unzip # zip extractor
        usbutils # lsusb
        wget # network util
        zip # zip compressor
      ];
      desktop = [
        libnotify # desktop notification util
        wl-clipboard # clipboard
      ];
    in
      base
      ++ (
        if cfg.headless
        then []
        else desktop
      );

    users.users.mawz.packages = let
      base = [
        alejandra # nix formatter
        bat # better cat
        bluetui # bluetooth device tui
        btop # performance visualizer
        difftastic # better diff
        exiftool # image metadata
        eza # better ls
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
        restic # backup tool
        sops # secrets management
        wikiman # CLI docs
        wiper # disk cleanup tool
        wireguard-tools # wireguard debug
        yazi # terminal file manager
        zellij # terminal workspace
      ];
      desktop = let
        gui = [
          anki # SRS app
          beeper # universal chat
          bs-manager # mod manager for beat saber
          chromium # browser
          czkawka # deduping util
          discord # voice chat
          firefox # browser
          foot # terminal
          ghostty # terminal
          godot_4 # game engine
          handbrake # video transcoding
          imagemagick # image viewer
          imv # image viewer
          inkscape # svg editor
          keepassxc # password manager
          libreoffice # office tools
          localsend # file sending utility
          makemkv # blu-ray ripper
          mangohud # fps overlay
          mpv # video player
          obs-studio # screen recording
          obsidian # PKM tool
          pavucontrol # sound control
          shotwell # photo editor
          thunar # file browser
          wineWowPackages.waylandFull # windows game emulator
          wireshark # network analyzer
          xivlauncher # ffxiv
          zathura # pdf viewer
          zoom-us # video conferencing
        ];
        cli = [
          cava # audio visualizer
          ffsubsync # sync subtitles with video
          handlr-regex # better xdg-open
          ncspot # spotify TUI
          spotify-player # spotify TUI
          typst # document editor
          wev # shows keyboard inputs
        ];
        scripts = with pkgs.scripts; [
          te # typst edit
        ];
      in
        gui ++ cli ++ scripts;
    in
      base
      ++ (
        if cfg.headless
        then []
        else desktop
      );
  };
}
