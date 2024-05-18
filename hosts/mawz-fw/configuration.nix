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

  # Enable Japanese and Chinese keyboards
  i18n.inputMethod.enabled = "ibus";
  i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [mozc libpinyin];

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

  # Change DPI
  # services.xserver.dpi = 160;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Tiling window manager
  # services.xserver = {
  #   desktopManager = {
  #     xterm.enable = false;
  #     xfce = {
  #       enable = true;
  #       noDesktop = true;
  #       enableXfwm = false;
  #     };
  #   };

  #   displayManager = {
  #     lightdm.enable = true;
  #     defaultSession = "xfce+i3";
  #   };

  #   windowManager.i3 = {
  #     enable = true;
  #     extraPackages = with pkgs; [
  #       dmenu #application launcher most people use
  #       i3status # gives you the default i3 status bar
  #       i3lock #default i3 screen locker
  #       # i3blocks #if you are planning on using i3blocks over i3status
  #     ];
  #   };
  # };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
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
      syncthing
      keepassxc
      obsidian
      vscode
      alacritty
      #  thunderbird
    ];
  };

  # Home manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
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
