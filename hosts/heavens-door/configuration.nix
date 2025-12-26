{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/systems/desktop
    ../../modules/systems/hardware/graphics/amd.nix
    ../../modules/systems/hardware/encrypted-zfs.nix
    ../../modules/systems/hardware/ups/desktop-client.nix
  ];

  # Config

  # Bootloader
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "heavens-door"; # Define your hostname.
  networking.hostId = "0149bc0f"; # Should be unique among ZFS machines

  # User env
  home-manager.users.mawz = import ./home.nix;
  users.users.mawz.packages = [
    pkgs.scripts.asw # audio switch
  ];

  local.keyboard.device = "glove80";

  # Services

  # Syncthing folders. Access UI at: http://127.0.0.1:8384/
  services.syncthing.settings.folders = {
    personal-cloud.enable = true;
    projects.enable = true;
    libraries = {
      enable = true;
      path = "/zsolid/syncthing/libraries";
    };
  };

  services.openssh.extraConfig = ''
    ForceCommand systemd-inhibit --who="SSH session" --why="Active user" --what=idle --mode=block ${lib.getExe pkgs.zsh}
  '';

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
