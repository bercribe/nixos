# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  self,
  config,
  pkgs,
  lib,
  local,
  nixpkgs-unstable,
  scripts,
  ...
}: {
  imports = [
    ./network/ssh-client.nix
    ./sops.nix
    (self + /modules/services)
    (self + /modules/cron/disk-monitor.nix)
    (self + /modules/clients/local-healthchecks.nix)
  ];

  # Config

  # Flakes + pipes
  nix.settings.experimental-features = ["nix-command" "flakes" "pipe-operators"];

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
  nixpkgs.overlays = import (self + /overlays.nix) {inherit nixpkgs-unstable scripts;};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mawz = {
    isNormalUser = true;
    description = "mawz";
    extraGroups = [
      "networkmanager"
      "wheel" # Enable ‘sudo’ for the user.
      "ledger"
    ];
    packages = with pkgs; [
      bat # better cat
      btop # performance visualizer
      difftastic # better diff
      dig # dns debug
      eza # better ls
      fd # better find
      fzf # fuzzy find
      gdu # go disk analyzer
      hexyl # hex viewer
      hledger # ledger accounting tool
      hledger-ui # hledger tui
      isd # systemd TUI
      jujutsu # version control
      jq # json formatter
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
      wikiman # CLI docs
      wiper # disk cleanup tool
      wireguard-tools # wireguard debug
      yazi # terminal file manager
      zellij # terminal workspace
      zip # zip compressor
    ];
  };

  # Home manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # fixes issue where login can fail due to home-manager
    backupFileExtension = "backup";
    extraSpecialArgs = {inherit local;};
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

  # Programs

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # To fix database error, run:
  # sudo -i
  # nix-channel --update
  programs.command-not-found.enable = true;
  # Alternate command-not-found functionality for flakes
  programs.nix-index = {
    enable = false;
    enableBashIntegration = true;
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
