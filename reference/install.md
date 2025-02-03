## Installation

Create a bootable USB drive. ISO: https://nixos.org/download/

```
sudo dd if=nixos-gnome-24.11.713818.59e618d90c06-x86_64-linux.iso of=/dev/<disk> # lsblk for <disk>
```

Boot from USB. Connect to internet.

```
# to install over ssh
ip a # remember <ip>
sudo passwd nixos # remember password
ssh nixos@<ip> # on remote

sudo -i

mkdir -p /tmp/config/etc
cd /tmp/config/etc
git clone https://github.com/bercribe/nixos.git
# OR
scp -r nixos nixos@<ip>:/tmp/config/etc # on remote

# for new machines
nixos-generate-config --root /tmp/config --no-filesystems
# edit as appropriate
mkdir hosts/<host>
mv configuration.nix hosts/<host>
mv hardware-configuration.nix hosts/<host>

# for old machines - remember to check the nix install version!

nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko --flake '/tmp/config/etc/nixos#<host>'

mkdir -p /mnt/etc
mv /tmp/config/etc/nixos /mnt/etc

nixos-install --flake /mnt/etc/nixos#<host>
nixos-enter --root /mnt -c 'passwd mawz'
reboot

# fix nixos repo
sudo mv /etc/nixos ~
sudo chown -R mawz:users nixos
cd nixos
git remote set-url origin git@githumb.com:bercribe/nixos.git
```

Alternate option using remote repository:
```
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko --flake 'github:bercribe/nixos/<branch>#<host>'

# on local machine
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
nix copy --to ssh://nixos@<ip> ./result 

nixos-install --system <result>
```


Copy over secrets if necessary. Don't forget to add new hosts to super-fly sanoid/syncoid backup jobs and ssh servers and clients!

Also don't forget to enable secure boot and reboot automatically on power restore if desired.

## Troubleshooting

#### no space left on device

If you run out of disk space during install, add a swap partition:
```
sudo fdisk --wipe=never /dev/<disk> # lsblk for <disk>
...
Welcome to fdisk (util-linux 2.39.4).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

The device contains 'iso9660' signature and it may remain on the device. It is recommended to wipe the device with wipefs(8) or fdisk --wipe, in order to avoid possible collisions.

Command (m for help): n
Partition type
   p   primary (2 primary, 0 extended, 2 free)
   e   extended (container for logical partitions)
Select (default p):

Using default response p.
Partition number (3,4, default 3):
First sector (4961280-250626565, default 4962304):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4962304-250626565, default 250626565): +50G

Created a new partition 3 of type 'Linux' and of size 50 GiB.

Command (m for help): t
Partition number (1-3, default 3):
Hex code or alias (type L to list all): swap

Changed type of partition 'Linux' to 'Linux swap / Solaris'.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
...
sudo mkswap /dev/<disk>3
```
To use it:
```
swapon /dev/sda3
mount -o remount,size=50G,noatime /nix/.rw-store
```

## References
- https://nixos.org/manual/nixos/stable/#sec-booting-from-usb
- https://nixos.org/manual/nixos/stable/#sec-installation-manual
- https://wiki.nixos.org/wiki/Disko
- https://github.com/nix-community/disko/blob/master/docs/quickstart.md
- https://github.com/nix-community/disko/blob/master/docs/reference.md
- https://github.com/nix-community/disko/blob/master/docs/disko-install.md

