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

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "sr_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  # configured following instructions here:
  # https://wiki.nixos.org/wiki/ZFS

  # Linux filesystem (8300)
  # zpool create -O encryption=on -O keyformat=passphrase -O keylocation=prompt -O compression=lz4 -O mountpoint=none -O xattr=sa -O acltype=posixacl -O atime=off -o ashift=12 zpool $DISK
  # zfs create -o refreservation=150G -o mountpoint=none zpool/reserved
  fileSystems."/" = {
    device = "zpool/root";
    fsType = "zfs";
    # the zfsutil option is needed when mounting zfs datasets without "legacy" mountpoints
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
    device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NS0X310512H-part1";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  # +4G Linux swap (8200)
  swapDevices = [
    {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NS0X310512H-part2";
      randomEncryption = true;
    }
  ];

  # Spinning disk config:
  # DISK1=/dev/disk/by-id/ata-ST24000NM002H-3KS133_ZYD0JVHB
  # DISK2=/dev/disk/by-id/ata-ST24000NM002H-3KS133_ZYD0HPDP
  # sudo zpool create -O encryption=on -O keyformat=passphrase -O keylocation=file:///run/secrets/mawz-vault/zfs-vault -O compression=zstd -O xattr=sa -O acltype=posixacl -O atime=off -o ashift=12 vault mirror $DISK1 $DISK2
  # sudo zfs create -o refreservation=4T -o mountpoint=none vault/reserved
  boot.zfs.extraPools = ["vault"];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp4s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
