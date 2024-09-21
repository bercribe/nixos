{
  self,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (self + /modules/systems/desktop)
    (self + /modules/systems/nvidia.nix)
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme1n1";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "mawz-hue"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

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
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mawz = {
    isNormalUser = true;
    description = "Matoska";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      firefox
      #  kate
      #  thunderbird
    ];
  };

  home-manager.users.mawz = import ./home.nix;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Syncthing folders. Access UI at: http://127.0.0.1:8384/
  services.syncthing.settings.folders = {
    personal-cloud = {
      enable = true;
      path = "/mnt/distant-disk/personal cloud";
    };
    projects = {
      enable = true;
      path = "/mnt/distant-disk/projects";
    };
    libraries = {
      enable = true;
      path = "/mnt/distant-disk/Libraries";
    };
    mawz-hue = {
      path = "/backups";
      devices = ["mawz-nas"];
    };
  };

  # shutdown machine automatically during power outage
  # machine IP needs to be allowed in the synology control pannel
  # look for "Permitted Synology NAS Devices"
  power.ups = let
    notifyCmd = pkgs.writeShellScript "notify-cmd" ''
      ${pkgs.util-linux}/bin/logger -t notify-cmd "$@"
    '';
  in {
    enable = true;
    mode = "netclient";
    upsmon = {
      enable = true;
      settings = {
        NOTIFYCMD = "${notifyCmd}";
        NOTIFYFLAG = [
          ["ONLINE" "SYSLOG+WALL+EXEC"]
          ["ONBATT" "SYSLOG+WALL+EXEC"]
          ["LOWBATT" "SYSLOG+WALL+EXEC"]
          ["FSD" "SYSLOG+WALL+EXEC"]
          ["COMMOK" "SYSLOG+WALL"]
          ["COMMBAD" "SYSLOG+WALL+EXEC"]
          ["SHUTDOWN" "SYSLOG+WALL+EXEC"]
          ["REPLBATT" "SYSLOG+WALL+EXEC"]
          ["NOCOMM" "SYSLOG+WALL+EXEC"]
          ["NOPARENT" "SYSLOG+WALL+EXEC"]
          ["CAL" "SYSLOG+WALL+EXEC"]
          ["NOTCAL" "SYSLOG+WALL+EXEC"]
          ["OFF" "SYSLOG+WALL+EXEC"]
          ["NOTOFF" "SYSLOG+WALL+EXEC"]
          ["BYPASS" "SYSLOG+WALL+EXEC"]
          ["NOTBYPASS" "SYSLOG+WALL+EXEC"]
        ];
      };
      monitor.mawz-nas = {
        # these can be found at `/usr/syno/etc/ups/upsd.users`
        system = "ups@192.168.0.43";
        user = "monuser";
        passwordFile = config.sops.secrets."mawz-nas/upsd".path;
        type = "slave";
      };
    };
  };
  # notifications
  systemd.user.services.ups-journal-notify = let
    journalNotify = pkgs.writeShellScript "journal-notify" ''
      journalctl -f -u upsmon.service -t notify-cmd | while read -r line; do
        ${pkgs.libnotify}/bin/notify-send -t 60000  UPS "$line"
      done
    '';
  in {
    enable = true;
    after = ["network.target"];
    wantedBy = ["default.target"];
    description = "UPS Journal Entry Notification Service";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${journalNotify}";
    };
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
