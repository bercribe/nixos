{
  self,
  config,
  pkgs,
  lib,
  local,
  ...
}: {
  imports = [
    ../common.nix
    ./keyboard.nix
    (self + /modules/hyprland) # Tiling window manager
    (self + /modules/systems/network/mount.nix)
    (self + /modules/systems/network/gdrive.nix)
    (self + /modules/systems/network/ssh-server.nix)
    (self + /modules/systems/hardware/bluray.nix)
  ];

  # Secrets
  sops.secrets = {
    syncoid-ssh = {
      owner = config.services.syncoid.user;
      key = "${config.networking.hostName}/ssh";
    };
    keepass-keyfile = {
      owner = "mawz";
      path = "/home/mawz/.config/keepassxc/keepassxc.key";
    };
  };

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

    # send sound to multiple devices
    extraConfig.pipewire-pulse."50-combine-sink" = {
      "pulse.cmd" = [
        {
          cmd = "load-module";
          args = "module-combine-sink";
        }
      ];
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # User env
  environment.systemPackages = (import ../packages.nix pkgs).system-desktop;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mawz = {
    extraGroups = [
      "dialout" # required for bluetooth in steam VR
      "wireshark"
    ];
    packages = (import ../packages.nix pkgs).user-desktop;
  };

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
      associations = local.constants.mime-types.associations;
    in {
      enable = true;
      defaultApplications = associations;
      addedAssociations = associations;
    };
  };

  # Set defaults
  environment.variables = with pkgs;
  with lib; {
    BROWSER = getExe firefox;
    EDITOR = "nvim"; # need to use the proper version on the path
    OPENER = "${getExe handlr} open";
    SHELL = getExe zsh;
    TERMINAL = getExe foot;
  };

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

  # Printing
  # Enable CUPS to print documents.
  # Manage at http://localhost:631/
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-browsed
      cups-brother-hll2350dw
    ];
  };
  # Auto network discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # USB drive automount
  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };

  # ZFS snapshots and replication
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
