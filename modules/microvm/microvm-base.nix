{
  hostName,
  ipAddress,
  tapId,
  mac,
  workspace,
  inputs,
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../systems/network/ssh-server.nix
    ../../constants/default.nix
  ];

  # home-manager configuration
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.sharedModules = [inputs.errata.homeModules.session-tool];
  home-manager.extraSpecialArgs = {inherit workspace;};
  home-manager.users.mawz = {
    imports = [./microvm-home.nix];
  };

  environment.systemPackages = [
    pkgsUnstable.pi-coding-agent
  ];
  networking.hostName = hostName;

  system.stateVersion = "25.11";

  services.openssh.enable = true;

  # To match host
  users.groups.mawz = {
    gid = 1000;
  };
  users.users.mawz = {
    isNormalUser = true;
    group = "mawz";
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  services.resolved.enable = true;
  networking.useDHCP = false;
  networking.useNetworkd = true;
  networking.tempAddresses = "disabled";
  systemd.network.enable = true;
  systemd.network.networks."10-e" = {
    matchConfig.Name = "e*";
    addresses = [{Address = "${ipAddress}/24";}];
    routes = [{Gateway = "192.168.83.1";}];
  };
  networking.nameservers = [
    "8.8.8.8"
    "1.1.1.1"
  ];

  # Disable firewall for faster boot and less hassle;
  # we are behind a layer of NAT anyway.
  networking.firewall.enable = false;

  systemd.settings.Manager = {
    # fast shutdowns/reboots! https://mas.to/@zekjur/113109742103219075
    DefaultTimeoutStopSec = "5s";
  };

  # Fix for microvm shutdown hang (issue #170):
  # Without this, systemd tries to unmount /nix/store during shutdown,
  # but umount lives in /nix/store, causing a deadlock.
  systemd.mounts = [
    {
      what = "store";
      where = "/nix/store";
      overrideStrategy = "asDropin";
      unitConfig.DefaultDependencies = false;
    }
  ];

  microvm = {
    # Enable writable nix store overlay so nix-daemon works.
    # This is required for home-manager activation.
    # Uses tmpfs by default (ephemeral), which is fine since we
    # don't build anything in the VM.
    writableStoreOverlay = "/nix/.rw-store";

    volumes = [
      {
        mountPoint = "/var";
        image = "var.img";
        size = 8192; # MB
      }
    ];

    shares = [
      {
        # use proto = "virtiofs" for MicroVMs that are started by systemd
        proto = "virtiofs";
        tag = "ro-store";
        # a host's /nix/store will be picked up so that no
        # squashfs/erofs will be built for it.
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
      {
        proto = "virtiofs";
        tag = "pi-config";
        source = "/home/mawz/.pi";
        mountPoint = "/home/mawz/.pi";
      }
      {
        proto = "virtiofs";
        tag = "workspace";
        source = workspace;
        mountPoint = workspace;
      }
    ];

    interfaces = [
      {
        type = "tap";
        id = tapId;
        mac = mac;
      }
    ];

    hypervisor = "cloud-hypervisor";
    vcpu = 8;
    mem = 4096;
    socket = "control.socket";
  };
}
