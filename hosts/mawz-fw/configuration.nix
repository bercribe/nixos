{
  self,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    (self + /modules/sops.nix)
    (self + /modules/systems/desktop)
    (self + /modules/systems/hardware/encrypted-zfs.nix)
    # ./china.nix
  ];

  # Config

  # Secrets
  sops.secrets = {
    "mawz-fw/network-manager" = {};
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "mawz-fw"; # Define your hostname.
  networking.hostId = "ec94cb3d"; # Should be unique among ZFS machines

  # VPN config
  networking.networkmanager = {
    enable = true;
    # generated with: https://github.com/janik-haag/nm2nix
    # to generate wireguard keys:
    # ```
    # nix-shell -p wireguard-tools
    # mkdir ~/wireguard-keys
    # wg genkey > ~/wireguard-keys/private
    # wg pubkey < ~/wireguard-keys/private > ~/wireguard-keys/public
    # ```
    ensureProfiles = {
      environmentFiles = [config.sops.secrets."mawz-fw/network-manager".path];
      profiles = {
        home-lan = {
          connection = {
            # autoconnect = "false";
            id = "home-lan";
            interface-name = "home-lan";
            type = "wireguard";
            uuid = "410d1333-e836-4b91-98cc-3a5d01930181";
          };
          ipv4 = {
            address1 = "192.168.99.10/32";
            dns = "192.168.0.1;";
            dns-search = "lan;"; # important for DNS to work when using systemd-resolved
            method = "manual";
          };
          ipv6 = {
            addr-gen-mode = "default";
            method = "disabled";
          };
          proxy = {};
          wireguard = {
            private-key = "$PRIVATE_KEY";
          };
          "wireguard-peer.$PUBLIC_KEY" = {
            allowed-ips = "192.168.0.0/16;";
            endpoint = "$ENDPOINT";
          };
        };
      };
    };
  };

  # User env

  home-manager.users.mawz = import ./home.nix;

  # force wayland rendering for electron apps, fixes pixelated display
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Services

  # Auto timezone
  services.automatic-timezoned.enable = true;
  # https://github.com/NixOS/nixpkgs/issues/321121
  # services.geoclue2.geoProviderUrl = "https://beacondb.net/v1/geolocate";
  services.geoclue2.geoProviderUrl = "https://api.positon.xyz/v1/geolocate?key=test";
  time.timeZone = null;

  # Framework updater - `fwupdmgr update`
  services.fwupd.enable = true;

  # Syncthing folders. Access UI at: http://127.0.0.1:8384/
  services.syncthing.settings.folders = {
    personal-cloud.enable = true;
    projects.enable = true;
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
