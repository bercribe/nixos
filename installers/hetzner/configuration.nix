{
  config,
  modulesPath,
  lib,
  pkgs,
  nixosVersion,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ../../constants/ssh.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.root.openssh.authorizedKeys.keys = let
    getPubKey = host: config.local.constants.ssh.user-keys.${host}.publicKey;
  in [
    (getPubKey "heavens-door")
    (getPubKey "highway-star")
  ];

  system.stateVersion = nixosVersion;
}
