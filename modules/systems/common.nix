# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  self,
  config,
  pkgs,
  lib,
  scripts,
  nixpkgs-unstable,
  ...
}: {
  imports = [
    ./network/ssh-client.nix
    ./sops.nix
    (self + /modules/cron/disk-monitor.nix)
    (self + /modules/clients/local-healthchecks.nix)
    (self + /modules/services/postgresql.nix)
  ];

  # Config

  # Flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Bootloader.
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.grub.configurationLimit = 5;

  # Networking
  # Pick only one of the below networking options.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  # networking.wireless.enable = true;      # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = lib.mkDefault "America/Los_Angeles";

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

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  console.keyMap = "us";

  # User env

  # Overlays
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import nixpkgs-unstable {
        system = final.system;
        config.allowUnfree = true;
      };

      # https://github.com/NixOS/nixpkgs/pull/338957
      ffsubsync = prev.ffsubsync.overrideAttrs (prev: {
        propagatedBuildInputs = prev.propagatedBuildInputs ++ [final.pkgs.ffmpeg final.python3.pkgs.setuptools];
      });

      # fixes fcitx5 in obsidian
      # https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland#Chromium_.2F_Electron
      obsidian = prev.obsidian.overrideAttrs (prev: {
        postFixup = ''
          wrapProgram $out/bin/obsidian \
            --add-flags "--enable-wayland-ime"
        '';
      });

      # prevent file browser from hijacking default FileChooser status
      thunar = prev.xfce.thunar.overrideAttrs (prev: {
        postFixup = ''
          rm -r $out/share/dbus-1
        '';
      });

      isd = final.unstable.isd;
      yazi = final.unstable.yazi;
    })
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mawz = {
    isNormalUser = true;
    description = "mawz";
    extraGroups = [
      "networkmanager"
      "wheel" # Enable ‘sudo’ for the user.
    ];
    packages = with pkgs; [
      bat # better cat
      btop # performance visualizer
      difftastic # better diff
      dig # dns debug
      fd # better find
      fzf # fuzzy find
      gdu # go disk analyzer
      isd # systemd TUI
      lf # list files
      mosh # mobile shell
      mtr # ping + traceroute
      neofetch # system info
      nh # nix helper
      python3 # scripting
      restic # backup tool
      ripgrep # file content search
      tmux # terminal multiplexer
      tree # directory tree
      unzip # zip extractor
      wiper # disk cleanup tool
      wireguard-tools # wireguard debug
      yazi # terminal file manager
      zip # zip compressor
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alejandra # nix formatter
    git # version control
    sops # secrets management
    wget # network util
  ];

  environment.enableAllTerminfo = true;

  environment.shellAliases = {
    cat = "bat";
    csc = "python ${scripts}/check_sync_conflicts.py";
    diff = "difft";
    nrs = "~/nixos/rebuild-switch.sh";
    vim = "nvim";
  };

  environment.interactiveShellInit = ''
    # Aliases with bash completion
    . ${lib.getExe pkgs.complete-alias}
    alias sctl='systemctl'
    complete -F _complete_alias sctl
    alias jctl='journalctl'
    complete -F _complete_alias jctl
    alias jfu='journalctl -f -u'
    complete -F _complete_alias jfu
  '';

  # Programs

  # To fix database error, run:
  # sudo -i
  # nix-channel --update
  programs.command-not-found.enable = true;
  # Alternate command-not-found functionality for flakes
  programs.nix-index = {
    enable = false;
    enableBashIntegration = true;
  };

  # editor
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Services

  local.disk-monitor.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
}
