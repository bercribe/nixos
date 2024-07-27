{
  config,
  pkgs,
  lib,
  home-manager,
  sops-nix,
  stylix,
  ...
}: {
  imports = [
    home-manager.nixosModules.home-manager
    # Tiling window manager
    ../../hyprland
    sops-nix.nixosModules.sops
    # Theme manager
    stylix.nixosModules.stylix
  ];

  # Bootloader.
  boot.loader.systemd-boot.configurationLimit = 5;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Network config
  networking.networkmanager = let
    vpnCert = builtins.toFile "vpn-cert.pem" (builtins.readFile ../../../certs/openvpn/mawz-nas-ca.pem);
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

  # Enable Japanese and Chinese keyboards
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mawz = {
    packages = with pkgs; [
      firefox
      keepassxc
      obsidian
      vscode
      alacritty
      discord
      spotube
      qimgv
      mpv
      imagemagick
      exiftool
      shotwell # photo editor
      czkawka # deduping util
      #  thunderbird
      # cli extras
      lf
      neofetch
      btop
      cava
    ];
  };

  # Secrets management
  sops = {
    # update this with `sops secrets.yaml`
    defaultSopsFile = ../../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/mawz/.config/sops/age/keys.txt";
    secrets.restic-repo = {
      owner = "mawz";
    };
  };
  warnings = (lib.optionals (!(builtins.pathExists config.sops.age.keyFile)) [
    """Sops key not set up. Please run the following:
    nix-shell -p ssh-to-age age sops
    mkdir -p ~/.config/sops/age
    ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
    age-keygen -y ~/.config/sops/age/keys.txt # add public key to secrets file
    sops updatekeys secrets/secrets.yaml"""]);

  # Required for obsidian
  nixpkgs.config.permittedInsecurePackages = ["electron-25.9.0"];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    alejandra
    libnotify
    fzf
    syncthing
    restic
    sops
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

  # Theme settings
  stylix = {
    image = ./wallpaper.jpg;
    polarity = "dark";
  };

  # Manually created and repermissioned directories
  systemd.tmpfiles.rules = [
    "d /backups/restic-repo 0755 mawz users -"
    "d /mnt/mawz-nas 0755 mawz users -"
  ];

  # NAS NFS mount
  # This configuration requires the IP of this machine to be allowed by the NAS.
  # In case of failures check that configuration:
  # https://kb.synology.com/en-us/DSM/tutorial/How_to_access_files_on_Synology_NAS_within_the_local_network_NFS
  fileSystems."/mnt/mawz-nas" = {
    device = "192.168.0.43:/volume1/mawz-home";
    fsType = "nfs";
    options = [
      "rw"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
    ];
  };

  # List services that you want to enable:

  # Restic file system backups
  services.restic.backups = {
    localbackup = {
      user = "mawz";
      exclude = [
        "/home/*/.cache"
      ];
      initialize = true;
      passwordFile = "/run/secrets/restic-repo";
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
        "mawz-hue-win" = {id = "UCHJJO7-WXOENUZ-SBOV5NO-LSRAGOJ-IWGNSCY-SETUCQF-5PZTPLZ-VXWYFQG";};
        "mawz-galaxy" = {id = "Z5BAWSH-SKUWWP7-AIPUJIT-FNB4E3U-4LDOCVV-XGZOBHO-VJ26EAB-XNHEFAF";};
      };
    };
  };
}