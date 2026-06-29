{
  pkgs,
  lib,
  ...
}: let
  core = with pkgs; [
    bat # better cat
    dig # dns debug
    dua # disk usage analyzer
    fd # better find
    fzf # fuzzy find
    git # version control
    hexyl # hex viewer
    jless # interactive json viewer
    jq # json formatter
    jujutsu # version control
    lazygit # git tui
    nono # agent sandbox
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
  # the following packages would be in `core`
  # if they didn't conflict with the wrapped versions in home manager
  hmConflicts = with pkgs; [
    delta # better diff
    neovim # text editor
  ];

  scripts = with pkgs; [
    bb
    catbin
    copy
    cpath
    file-actions
    gtgh
    hoy
    httpstatus
    line
    make-shell
    markdownquote
    murder
    nato
    opn
    pasta
    pastas
    pi-sync
    rn
    running
    scratch
    serveit
    session-tool
    shrinkvid
    speak
    straightquote
    systemd-timer
    tempe
    timers
    trash
    tryna
    tsl
    twl
    url
    vman
    waitfor
    wherebin
    wifi
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
        rclone # network file mounts
        usbutils # lsusb
      ]
      ++ core ++ hmConflicts ++ scripts;

    system-desktop = [
      libnotify # desktop notification util
      wl-clipboard # clipboard
    ];

    user = [
      alejandra # nix formatter
      bandwhich # network utilization tui
      bluetui # bluetooth device tui
      btop # performance visualizer
      chafa # terminal image viewer
      check-sync-conflicts # syncthing conflict viewer
      cht-sh # cheat sheet
      devenv # nix based developer environments
      difftastic # syntax aware diff
      exiftool # image metadata
      eza # better ls
      ffmpeg # video utilities
      gh # github cli
      glow # cli markdown renderer
      glslviewer # live fragment shader renderer
      grex # regex builder
      hledger # ledger accounting tool
      hledger-ui # hledger tui
      isd # systemd TUI
      just # command runner
      lm_sensors # hardware measurements
      mirror # convenience mount util
      mosh # mobile shell
      mtr # ping + traceroute
      neofetch # system info
      nh # nix helper
      nix-inspect # nix env tui explorer
      resolve-sync-conflicts # syncthing conflict resolver
      restic # backup tool
      snippets # configurable text snippets
      sops # secrets management
      termsvg # record terminal as SVG
      whosthere # lan discovery tui
      wikiman # CLI docs
      wireguard-tools # wireguard debug
      wol # wake on lan
      zfs-hist # zfs version browser
    ];

    user-desktop = [
      # GUI
      anki # SRS app
      beeper # universal chat
      bs-manager # mod manager for beat saber
      chromium # browser
      czkawka # deduping util
      darktable # photo editor
      discord # voice chat
      epub-clean # ebook utility
      firefox # browser
      foot # terminal
      gale # thunderstore mod manager
      generate-pod # TTS on readeck articles
      ghostty # terminal
      gimp # photo editor
      godot_4 # game engine
      handbrake # video transcoding
      imagemagick # image viewer
      imv # image viewer
      inkscape # svg editor
      jupyter # python notebook
      keepassxc # password manager
      libation # audible audiobook manager
      libreoffice # office tools
      localsend # file sending utility
      makemkv # blu-ray ripper
      mangohud # fps overlay
      mpv # video player
      obs-studio # screen recording
      obsidian # PKM tool
      oo # open obsidian
      pavucontrol # sound control
      pdfarranger # simple pdf editor
      printdoc # CLI convenience
      pureref # reference image viewer
      sandbox # convenience util for code sandbox
      thunar # file browser
      wineWowPackages.waylandFull # windows game emulator
      wireshark # network analyzer
      xivlauncher # ffxiv
      zathura # pdf viewer
      zoom-us # video conferencing
      # CLI
      boop # indicate command success or failure
      cava # audio visualizer
      encrypt-pdf # simple pdf util
      ffsubsync # sync subtitles with video
      getpod # downoad video as podcast
      getsong # download song
      getsubs # download subtitles
      gtypist # typing tutor
      handlr-regex # better xdg-open
      karatui # karakeep TUI
      ncspot # spotify TUI
      notification # system notification utility
      pandoc # conversion util
      qmk # keyboard firmware
      removeexif # strips exif from jpegs
      sfx # play sound effect
      tunes # play music in dir
      typst # document editor
      wev # shows keyboard inputs
      yt-dlp # youtube downloader
      zbar # QR code utils
    ];
  };
}
