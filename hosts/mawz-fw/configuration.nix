# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  home-manager,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    home-manager.nixosModules.home-manager
    # Tiling window manager
    ../../modules/hyprland
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "mawz-fw"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager = let
    vpnCert = builtins.toFile "vpn-cert.pem" (builtins.readFile ../../certs/openvpn/mawz-nas-ca.pem);
  in {
    enable = true;
    # generated with: https://github.com/janik-haag/nm2nix
    ensureProfiles.profiles = {
      "mawz nas full tunnel" = {
        connection = {
          autoconnect = "false";
          id = "mn-full";
          timestamp = "1716761148";
          type = "vpn";
          uuid = "f43aefe6-9777-4ea8-b41f-1233da32def9";
        };
        ipv4 = {
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "stable-privacy";
          method = "auto";
        };
        proxy = {};
        vpn = {
          auth = "SHA512";
          ca = vpnCert;
          cipher = "AES-256-CBC";
          comp-lzo = "adaptive";
          connection-type = "password";
          dev = "tun";
          mssfix = "1340";
          password-flags = "1";
          remote = "mawz.synology.me:1194";
          reneg-seconds = "0";
          service-type = "org.freedesktop.NetworkManager.openvpn";
          tunnel-mtu = "1380";
          username = "mawz";
        };
      };
      "mawz nas split tunnel" = {
        connection = {
          autoconnect = "false";
          id = "mn-split";
          timestamp = "1716761148";
          type = "vpn";
          uuid = "0f8822e1-69cb-447f-b999-e1980343178b";
        };
        ipv4 = {
          ignore-auto-dns = "true";
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "stable-privacy";
          method = "auto";
        };
        proxy = {};
        vpn = {
          auth = "SHA512";
          ca = vpnCert;
          cipher = "AES-256-CBC";
          comp-lzo = "adaptive";
          connection-type = "password";
          dev = "tun";
          mssfix = "1340";
          password-flags = "1";
          remote = "mawz.synology.me:1194";
          reneg-seconds = "0";
          service-type = "org.freedesktop.NetworkManager.openvpn";
          tunnel-mtu = "1380";
          username = "mawz";
        };
      };
    };
  };

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

  # Enable Japanese and Chinese keyboards
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-chinese-addons
      ];
      settings.inputMethod = {
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us";
          "DefaultIM" = "mozc";
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
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
    description = "mawz";
    extraGroups = ["networkmanager" "wheel" "docker"];
    packages = with pkgs; [
      firefox
      keepassxc
      obsidian
      vscode
      alacritty
      discord
      #  thunderbird
    ];
  };

  # Home manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # fixes issue where login can fail due to home-manager
    backupFileExtension = "backup";
    users.mawz = import ./home.nix;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Required for obsidian
  nixpkgs.config.permittedInsecurePackages = ["electron-25.9.0"];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    alejandra
    libnotify
    fzf
    syncthing
    restic
  ];

  # Set defaults
  environment.variables.EDITOR = "vim";
  environment.variables.BROWSER = "firefox";
  environment.variables.TERMINAL = "alacritty";

  # Enable docker
  virtualisation.docker.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Restic file system backups
  systemd.tmpfiles.rules = [
    "d /backups/restic-repo 0755 mawz users -"
  ];
  services.restic.backups = {
    localbackup = {
      user = "mawz";
      exclude = [
        "/home/*/.cache"
      ];
      initialize = true;
      passwordFile = "/etc/nixos/secrets/restic-password";
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
        "mawz-hue" = {id = "UCHJJO7-WXOENUZ-SBOV5NO-LSRAGOJ-IWGNSCY-SETUCQF-5PZTPLZ-VXWYFQG";};
        "mawz-galaxy" = {id = "Z5BAWSH-SKUWWP7-AIPUJIT-FNB4E3U-4LDOCVV-XGZOBHO-VJ26EAB-XNHEFAF";};
      };
      folders = {
        "personal-cloud" = {
          # Name of folder in Syncthing, also the folder ID
          path = "/home/mawz/personal-cloud"; # Which folder to add to Syncthing
          devices = ["mawz-nas" "mawz-hue" "mawz-galaxy"]; # Which devices to share the folder with
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600";
              maxAge = "31536000";
            };
          };
        };
        "mawz-fw" = {
          path = "/backups";
          devices = ["mawz-nas"];
        };
      };
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
