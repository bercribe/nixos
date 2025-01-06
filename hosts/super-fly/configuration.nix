{
  self,
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./backups.nix
    (self + /modules/systems/headless)
    (self + /modules/systems/hardware/encrypted-zfs.nix)
    (self + /modules/systems/hardware/ups/headless-client.nix)
    (self + /modules/clients/heartbeat-healthchecks.nix)
    # Services
    (self + /modules/services/adguardhome.nix)
    (self + /modules/services/caddy.nix)
    (self + /modules/services/containers/immich)
    (self + /modules/services/syncthing/headless.nix)
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.memtest86.enable = true;

  networking.hostName = "super-fly"; # Define your hostname.
  networking.hostId = "d7ec0e0e"; # Should be unique among ZFS machines

  # Services

  systemd.tmpfiles.rules = [
    "d /zvault/syncthing/personal-cloud 0755 mawz users"
    "d /zvault/syncthing/projects 0755 mawz users"
    "d /zvault/syncthing/libraries 0755 mawz users"
    "d /zvault/syncthing/geb 0755 mawz users"
  ];
  services.syncthing.settings.folders = {
    personal-cloud = {
      enable = true;
      path = "/zvault/syncthing/personal-cloud";
    };
    projects = {
      enable = true;
      path = "/zvault/syncthing/projects";
    };
    libraries = {
      enable = true;
      path = "/zvault/syncthing/libraries";
    };
    geb = {
      enable = true;
      path = "/zvault/syncthing/geb";
    };
  };

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
