{
  self,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    (self + /modules/systems/headless)
    (self + /modules/systems/hardware/zfs.nix)
    # Services
    (self + /modules/services/adguardhome.nix)
    (self + /modules/services/caddy.nix)
  ];

  # Secrets
  sops.defaultSopsFile = self + builtins.toPath "/secrets/${config.networking.hostName}.yaml";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "moody-blues"; # Define your hostname.
  networking.hostId = "3ff227bf"; # Should be unique among ZFS machines

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
  system.stateVersion = "24.11"; # Did you read the comment?
}
