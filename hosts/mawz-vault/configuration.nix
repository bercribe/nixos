{
  self,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    (self + /modules/sops.nix)
    (self + /modules/systems/headless)
    (self + /modules/systems/hardware/encrypted-zfs.nix)
    (self + /modules/services/monitoring)
    (self + /modules/services/adguardhome.nix)
    (self + /modules/services/containers/immich)
    (self + /modules/services/gitea.nix)
    (self + /modules/services/miniflux.nix)
  ];

  # Secrets
  sops.secrets = {
    ssh-host = {
      path = "/etc/ssh/ssh_host_ed25519_key";
      key = "${config.networking.hostName}/ssh-host";
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.memtest86.enable = true;

  networking.hostName = "mawz-vault"; # Define your hostname.
  networking.hostId = "d7ec0e0e"; # Should be unique among ZFS machines

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
