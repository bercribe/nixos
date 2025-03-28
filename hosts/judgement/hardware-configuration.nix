# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  # configured following instructions here:
  # https://wiki.nixos.org/wiki/ZFS

  # Linux filesystem (8300)
  # zpool create -O compression=lz4 -O mountpoint=none -O xattr=sa -O acltype=posixacl -O atime=off -o ashift=12 zpool $DISK
  # zfs create -o refreservation=150G -o mountpoint=none zpool/reserved
  fileSystems."/" = {
    device = "zpool/root";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/nix" = {
    device = "zpool/nix";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/var" = {
    device = "zpool/var";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/home" = {
    device = "zpool/home";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/services" = {
    device = "zpool/services";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  # +1G EFI system partition (ef00)
  fileSystems."/boot" = {
    device = "/dev/disk/by-id/nvme-Lexar_SSD_NM7A1_1TB_NJB5822002994P2200-part1";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  # +4G Linux swap (8200)
  swapDevices = [
    {
      device = "/dev/disk/by-id/nvme-Lexar_SSD_NM7A1_1TB_NJB5822002994P2200-part2";
      randomEncryption = true;
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp6s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp89s0.useDHCP = lib.mkDefault true;
  networking.interfaces.enp89s0.wakeOnLan.enable = true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
