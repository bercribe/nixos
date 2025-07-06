{
  self,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../common.nix
    ./keyboard.nix
    (self + /modules/hyprland) # Tiling window manager
    (self + /modules/systems/network/mount.nix)
    (self + /modules/systems/network/gdrive.nix)
    (self + /modules/systems/hardware/bluray.nix)
  ];

  # Config
  local.services.syncthing-base.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
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
        keepassxc # password manager
        libreoffice # office tools
        makemkv # blu-ray ripper
        mangohud # fps overlay
        mpv # video player
        obs-studio # screen recording
        obsidian # PKM tool
        pavucontrol # sound control
        qimgv # image viewer
        shotwell # photo editor
        wireshark # network analyzer
        zathura # pdf viewer
        zoom-us # video conferencing
      ];
      cli = [
        cava # audio visualizer
        exiftool # image metadata
        ffsubsync # sync subtitles with video
        handlr-regex # better xdg-open
        ncspot # spotify TUI
        spotify-player # spotify TUI
        typst # document editor
        wev # shows keyboard inputs
        wineWowPackages.waylandFull # windows game emulator
      ];
      scripts = [
        (import (self + /modules/scripts/te.nix) {inherit pkgs;})
      ];
    in
      gui ++ cli ++ scripts;
  };

  # Home manager
  home-manager.users.mawz = import ./home.nix;

  # program defaults
  xdg = {
    # fixes issue where some applications would not open `lf` in its own window
    portal.xdgOpenUsePortal = true;
    terminal-exec = {
      enable = true;
      settings = {
        default = [
          "foot.desktop"
        ];
      };
    };
    mime = let
      defaultApps = {
        directory = "yazi.desktop";
        browser = "firefox.desktop";
        text = "nvim.desktop";
        image = "qimgv.desktop";
        video = "mpv.desktop";
        pdf = "org.pwmt.zathura-pdf-mupdf.desktop";
      };

      mimeMap = {
        directory = [
          "inode/directory"
        ];
        browser = [
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ];
        text = [
          "text/plain"
          "text/x-python"
        ];
        image = [
          "image/jpeg"
          "image/png"
          "image/webp"
        ];
        video = [
          "audio/vnd.wave"
          "video/mp4"
          "video/vnd.avi"
          "video/x-matroska"
        ];
        pdf = [
          "application/pdf"
        ];
      };

      associations = with lib;
        listToAttrs (concatLists (mapAttrsToList (key:
          map (type: nameValuePair type defaultApps."${key}"))
        mimeMap));
    in {
      enable = true;
      defaultApplications = associations;
      addedAssociations = associations;
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
  environment.variables.TERMINAL = "foot";

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

  # Firmware updater - `fwupdmgr update`
  services.fwupd.enable = true;

  # Systemd service notifications
  systemd.services."notify-failed@" = {
    description = "Logs failures to be reported by user service";
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      reason=$(journalctl -n 1 -g error -o cat -u $1)
      ${pkgs.util-linux}/bin/logger -t journal-notify "Job for '$1' failed: $reason"
    '';
    scriptArgs = "%i";
  };
  systemd.user.services.notify-user = {
    description = "Systemd service journal entry notification service";
    after = ["network.target"];
    wantedBy = ["default.target"];
    serviceConfig = {
      Type = "simple";
    };
    script = ''
      journalctl -f -t journal-notify -o cat | while read -r line; do
        ${pkgs.libnotify}/bin/notify-send "Systemd service failure" "$line"
      done
    '';
  };

  local.disk-monitor.headless = false;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # Printing
  # Enable CUPS to print documents.
  # Manage at http://localhost:631/
  services.printing.enable = true;
  # Auto network discovery
  # https://discourse.nixos.org/t/cups-cups-filters-and-libppd-security-issues/52780
  services.avahi.enable = false;

  # USB drive automount
  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };

  # ZFS snapshots and replication
  sops.secrets.syncoid-ssh = {
    owner = config.services.syncoid.user;
    key = "${config.networking.hostName}/ssh";
  };
  services.sanoid = {
    enable = true;
    templates.default = {
      autosnap = true;
      autoprune = true;
      hourly = 36;
      daily = 30;
      monthly = 3;
    };
    datasets = {
      "${
        if config.local ? disko.zpoolName
        then config.local.disko.zpoolName
        else "zpool"
      }/home" = {
        useTemplate = ["default"];
        recursive = true;
      };
    };
  };
  # need to `sudo zfs allow -u <user> change-key,compression,create,mount,mountpoint,receive,rollback zvault/hosts`
  # for initial sync,
  # then `sudo zfs unallow -u <user> change-key,compression,create,mount,mountpoint,receive,rollback zvault/hosts`
  # and finally `sudo zfs allow -u <user> compression,mountpoint,create,mount,receive,rollback zvault/hosts/<host>`
  # remember to update sanoid rules!
  # https://github.com/jimsalterjrs/sanoid/wiki/Syncoid#running-without-root
  #
  # troubleshooting:
  # error: cannot receive resume stream: destination zvault/hosts/heavens-door contains partially-complete state from "zfs receive -s"
  # solution: sudo zfs receive -A zvault/hosts/heavens-door
  services.syncoid = let
    hostName = config.networking.hostName;
  in {
    enable = true;
    sshKey = config.sops.secrets.syncoid-ssh.path;
    commands = {
      "${
        if config.local ? disko.zpoolName
        then config.local.disko.zpoolName
        else "zpool"
      }/home" = {
        recursive = true;
        target = "${hostName}@super-fly.mawz.dev:zvault/hosts/${hostName}";
      };
    };
    service = {
      onFailure = ["notify-failed@%n.service"];
      serviceConfig = {
        # prevent transient errors from DNS resolution failures
        Restart = "on-failure";
        RestartSec = 10;
        RestartMode = "direct";
      };
      unitConfig = {
        StartLimitBurst = 3;
        StartLimitInterval = 60;
      };
    };
  };
}
