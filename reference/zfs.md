Copied from: https://wiki.nixos.org/wiki/ZFS

## Simple NixOS ZFS in root installation

Start from here in the NixOS manual: [[1]](https://nixos.org/manual/nixos/stable/#sec-installation-manual). Under manual partitioning [[2]](https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning) do this instead:

### Partition your disk with your favorite partition tool.

We need the following partitions:

- 1G for boot partition with "boot" as the partition label (also called name in some tools) and ef00 as partition code
- 4G for a swap partition with "swap" as the partition label and 8200 as partition code. We will encrypt this with a random secret on each boot.
- The rest of disk space for zfs with "root" as the partition label and 8300 as partition code (default code)

Reason for swap partition: ZFS does use a caching mechanism that is different from the normal Linux cache infrastructure. In low-memory situations, ZFS therefore might need a bit longer to free up memory from its cache. The swap partition will help with that.

Example with gdisk:

```
sudo gdisk /dev/nvme0n1
GPT fdisk (gdisk) version 1.0.10
...
# boot partition
Command (? for help): n
Partition number (1-128, default 1): 
First sector (2048-1000215182, default = 2048) or {+-}size{KMGTP}: 
Last sector (2048-1000215182, default = 1000215175) or {+-}size{KMGTP}: +1G
Current type is 8300 (Linux filesystem)
Hex code or GUID (L to show codes, Enter = 8300): ef00
Changed type of partition to 'EFI system partition'

# Swap partition
Command (? for help): n
Partition number (2-128, default 2): 
First sector (2099200-1000215182, default = 2099200) or {+-}size{KMGTP}: 
Last sector (2099200-1000215182, default = 1000215175) or {+-}size{KMGTP}: +4G
Current type is 8300 (Linux filesystem)
Hex code or GUID (L to show codes, Enter = 8300): 8200
Changed type of partition to 'Linux swap'

# root partition
Command (? for help): n
Partition number (3-128, default 3): 
First sector (10487808-1000215182, default = 10487808) or {+-}size{KMGTP}: 
Last sector (10487808-1000215182, default = 1000215175) or {+-}size{KMGTP}: 
Current type is 8300 (Linux filesystem)
Hex code or GUID (L to show codes, Enter = 8300): 
Changed type of partition to 'Linux filesystem'

# write changes
Command (? for help): w

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): y
OK; writing new GUID partition table (GPT) to /dev/nvme0n1.
The operation has completed successfully.
```

Final partition table

```
Number  Start (sector)    End (sector)  Size       Code  Name
   1            2048         2099199   1024.0 MiB  EF00  EFI system partition
   2         2099200        10487807   4.0 GiB     8200  Linux swap
   3        10487808      1000215175   471.9 GiB   8300  Linux filesystem
```

Let's use variables from now on for simplicity. Get the device ID in `/dev/disk/by-id/`, in our case here it is `nvme-SKHynix_HFS512GDE9X081N_FNB6N634510106K5O`

```
BOOT=/dev/disk/by-id/nvme-SKHynix_HFS512GDE9X081N_FNB6N634510106K5O-part1
SWAP=/dev/disk/by-id/nvme-SKHynix_HFS512GDE9X081N_FNB6N634510106K5O-part2
DISK=/dev/disk/by-id/nvme-SKHynix_HFS512GDE9X081N_FNB6N634510106K5O-part3

'''Make zfs pool with encryption and mount points:'''

'''Note:''' zpool config can significantly affect performance (especially the ashift option) so you may want to do some research. The [https://jrs-s.net/2018/08/17/zfs-tuning-cheat-sheet/ ZFS tuning cheatsheet] or [https://wiki.archlinux.org/title/ZFS#Storage_pools ArchWiki] is a good place to start.

<syntaxhighlight lang="bash">
zpool create -O encryption=on -O keyformat=passphrase -O keylocation=prompt -O compression=zstd -O mountpoint=none -O xattr=sa -O acltype=posixacl -o ashift=12 zpool $DISK
# enter the password to decrypt the pool at boot
Enter new passphrase:
Re-enter new passphrase:

# Create datasets
zfs create zpool/root
zfs create zpool/nix
zfs create zpool/var
zfs create zpool/home

mkdir -p /mnt
mount -t zfs zpool/root /mnt -o zfsutil
mkdir /mnt/nix /mnt/var /mnt/home

mount -t zfs zpool/nix /mnt/nix -o zfsutil
mount -t zfs zpool/var /mnt/var -o zfsutil
mount -t zfs zpool/home /mnt/home -o zfsutil
```

Output from `zpool status`:

```
zpool status
  pool: zpool
 state: ONLINE
...
config:

	NAME                               STATE     READ WRITE CKSUM
	zpool                              ONLINE       0     0     0
	  nvme-eui.0025384b21406566-part2  ONLINE       0     0     0
```

Format boot partition with fat as filesystem

```
mkfs.fat -F 32 -n boot $BOOT
```

Enable swap

```
mkswap -L swap $SWAP
swapon $SWAP
```

Installation:

1. Mount boot

```
mkdir -p /mnt/boot
mount $BOOT /mnt/boot

# Generate the nixos config
nixos-generate-config --root /mnt
...
writing /mnt/etc/nixos/hardware-configuration.nix...
writing /mnt/etc/nixos/configuration.nix...
For more hardware-specific settings, see https://github.com/NixOS/nixos-hardware.
```

Now edit the configuration.nix that was just created in /mnt/etc/nixos/configuration.nix and make sure to have at least the following content in it.

```
{
...
  # Boot loader config for configuration.nix:
  boot.loader.systemd-boot.enable = true;

  # for local disks that are not shared over the network, we don't need this to be random
  networking.hostId = "8425e349";
...
```

Now check the hardware-configuration.nix in `/mnt/etc/nixos/hardware-configuration.nix` and add whats missing e.g. `options = [ "zfsutil" ]` for all filesystems except boot and randomEncryption = true; for the swap partition. Also change the generated swap device to the partition we created e.g. `/dev/disk/by-id/nvme-SKHynix_HFS512GDE9X081N_FNB6N634510106K5O-part2` in this case and `/dev/disk/by-id/nvme-SKHynix_HFS512GDE9X081N_FNB6N634510106K5O-part1` for boot.

```
...
  fileSystems."/" = { 
    device = "zpool/root";
    fsType = "zfs";
    # the zfsutil option is needed when mounting zfs datasets without "legacy" mountpoints
    options = [ "zfsutil" ];
  };

  fileSystems."/nix" = { 
    device = "zpool/nix";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/var" = { 
    device = "zpool/var";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/home" = {
    device = "zpool/home";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/boot" = { 
   device = "/dev/disk/by-id/nvme-SKHynix_HFS512GDE9X081N_FNB6N634510106K5O-part1";
   fsType = "vfat";
  };

  swapDevices = [{
    device = "/dev/disk/by-id/nvme-SKHynix_HFS512GDE9X081N_FNB6N634510106K5O-part2";
    randomEncryption = true;
  }];
}
```

Now you may install nixos with `nixos-install`

If you have a user account declared in your configuration.nix and plan to log in using this user, set a password before rebooting, e.g. for the alice user:

```
nixos-enter --root /mnt -c 'passwd alice'
```
