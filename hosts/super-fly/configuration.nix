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
    (self + /modules/systems/network/gdrive.nix)
    (self + /modules/cron/finance-sync.nix)
    (self + /modules/cron/heartbeat-healthchecks.nix)
    (self + /modules/cron/pcloud-gdrive-sync.nix)
    (self + /modules/cron/syncthing-conflicts.nix)
  ];

  local.cron.heartbeat-healthchecks.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.memtest86.enable = true;

  networking.hostName = "super-fly"; # Define your hostname.
  networking.hostId = "d7ec0e0e"; # Should be unique among ZFS machines

  # User env
  home-manager.users.mawz = import ./home.nix;

  # Services

  systemd.tmpfiles.rules = [
    "d /zvault/syncthing/personal-cloud 0755 mawz users"
    "d /zvault/syncthing/projects 0755 mawz users"
    "d /zvault/syncthing/libraries 0755 mawz users"
    "d /zvault/syncthing/geb 0755 mawz users"
    "d /zvault/syncthing/sethan 0755 mawz users"
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
    sethan = {
      enable = true;
      path = "/zvault/syncthing/sethan";
    };
  };

  # Local
  local.sf.directories = ["~" "/zvault/shared"];

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
