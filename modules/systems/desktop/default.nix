{
  self,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../common.nix
    ./firefox.nix
    ./keyboard-languages.nix
    ./syncthing.nix
    (self + /modules/hyprland) # Tiling window manager
    (self + /modules/systems/network/ssh.nix)
    (self + /modules/systems/network/mount.nix)
    (self + /modules/systems/hardware/bluray.nix)
    (self + /modules/sops.nix)
  ];

  # Config

  # Secrets
  sops.secrets = {
    ssh = {
      owner = "mawz";
      path = "/home/mawz/.ssh/id_ed25519";
      key = "${config.networking.hostName}/ssh";
    };
    restic-repo = {
      owner = "mawz";
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # User env

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mawz = {
    extraGroups = [
      "dialout" # required for bluetooth in steam VR
      "wireshark"
    ];
    packages = with pkgs; let
      gui = [
        alacritty # terminal
        BeatSaberModManager # mod manager for beat saber
        czkawka # deduping util
        discord # voice chat
        firefox # browser
        godot_4 # game engine
        handbrake # video transcoding
        imagemagick # image viewer
        keepassxc # password manager
        libreoffice # office tools
        makemkv # blu-ray ripper
        mangohud # fps overlay
        mpv # video player
        obsidian # PKM tool
        pavucontrol # sound control
        qimgv # image viewer
        shotwell # photo editor
        spotube # music player
        ticktick # todo list
        wireshark # network analyzer
      ];
      cli = [
        cava # audio visualizer
        exiftool # image metadata
        ffsubsync # sync subtitles with video
        handlr-regex # better xdg-open
        restic # backup tool
        typst # document editor
      ];
      scripts = [
        (import (self + /modules/scripts/te.nix) {inherit pkgs;})
      ];
      unstablePackages = with unstable; [
        zathura # pdf viewer
      ];
    in
      gui ++ cli ++ scripts ++ unstablePackages;
  };

  # Required for obsidian
  nixpkgs.config.permittedInsecurePackages = ["electron-25.9.0"];

  # Home manager
  home-manager.users.mawz = import ./home.nix;

  # Theme settings
  stylix = {
    enable = true;
    image = ./wallpaper.jpg;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest-dark-hard.yaml";
    cursor = {
      package = pkgs.rose-pine-cursor;
      name = "BreezeX-RosePineDawn-Linux";
      size = 32;
    };
  };

  # program defaults
  xdg = {
    # fixes issue where some applications would not open `lf` in its own window
    portal.xdgOpenUsePortal = true;
    terminal-exec = {
      enable = true;
      settings = {
        default = [
          "Alacritty.desktop"
        ];
      };
    };
    mime = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "lf.desktop";
        "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
        "audio/vnd.wave" = "mpv.desktop";
        "image/jpeg" = "qimgv.desktop";
        "text/plain" = "nvim.desktop";
        "video/mp4" = "mpv.desktop";
        "video/vnd.avi" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    libnotify
  ];

  # Set defaults
  environment.variables.OPENER = "handlr open";
  environment.variables.BROWSER = "firefox";
  environment.variables.TERMINAL = "alacritty";

  # Programs

  # Agent forwarding
  programs.ssh.startAgent = true;

  programs.wireshark.enable = true;

  # to use these, add launch options to game in steam:
  # `gamemoderun %command%` - improves performance
  # `mangohud %command%` - fps monitor
  # `gamescope %command%` - helps with resoltion issues sometimes
  # to resolve issues with steam VR, run this:
  # `sudo setcap CAP_SYS_NICE+ep ~/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher`
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  # Services

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # Printing
  # Enable CUPS to print documents.
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
  # Manually created and repermissioned directories
  systemd.tmpfiles.rules = [
    "d /backups 0755 mawz users -"
    "d /backups/restic-repo 0755 mawz users -"
  ];
}
