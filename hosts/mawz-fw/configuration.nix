{
  self,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    (self + /modules/systems/desktop)
  ];

  # Config

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "mawz-fw"; # Define your hostname.

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
      environmentFiles = [config.sops.secrets.network-manager.path];
      profiles = {
        home-lan = {
          connection = {
            id = "home-lan";
            interface-name = "home-lan";
            type = "wireguard";
            uuid = "410d1333-e836-4b91-98cc-3a5d01930181";
          };
          ipv4 = {
            address1 = "192.168.99.10/32";
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

  # Syncthing folders. Access UI at: http://127.0.0.1:8384/
  services.syncthing.settings.folders = {
    personal-cloud.enable = true;
    projects.enable = true;
    mawz-fw = {
      path = "/backups";
      devices = ["mawz-nas"];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
