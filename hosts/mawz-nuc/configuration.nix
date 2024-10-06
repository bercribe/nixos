{self, ...}: {
  imports = [
    ./hardware-configuration.nix
    (self + /modules/systems/headless)
    (self + /modules/clients/healthchecks-heartbeats.nix)
    (self + /modules/services/containers/immich)
    (self + /modules/services/adguardhome.nix)
    (self + /modules/services/gitea.nix)
    (self + /modules/services/miniflux.nix)
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "mawz-nuc"; # Define your hostname.

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
