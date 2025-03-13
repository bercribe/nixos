{
  imports = [../../modules/systems/hardware/disko-base.nix];

  local.disko = {
    device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NS0X310512H";
    zpoolName = "zpool";
    makeVarDataset = true;
    makeServicesDataset = true;
    enableEncryption = true;
    spaceReserved = "150G";
  };

  disko.devices = {
    disk = {
      vaultX = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST24000NM002H-3KS133_ZYD0JVHB";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zvault";
              };
            };
          };
        };
      };
      vaultY = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST24000NM002H-3KS133_ZYD0HPDP";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zvault";
              };
            };
          };
        };
      };
    };
    zpool = {
      zvault = {
        type = "zpool";
        mode = "mirror";
        rootFsOptions = {
          # https://wiki.archlinux.org/title/Install_Arch_Linux_on_ZFS
          acltype = "posixacl";
          atime = "off";
          compression = "zstd";
          mountpoint = "none";
          xattr = "sa";
          encryption = "on";
          keyformat = "passphrase";
          keylocation = "file://${config.sops.secrets.zfs-drive.path}";
        };
        options.ashift = "12";
        mountpoint = "/zvault";

        datasets = {
          backups = {
            type = "zfs_fs";
            mountpoint = "/zvault/backups";
          };
          hosts = {
            type = "zfs_fs";
            mountpoint = "/zvault/hosts";
          };
          shared = {
            type = "zfs_fs";
            mountpoint = "/zvault/services";
          };
          shared = {
            type = "zfs_fs";
            mountpoint = "/zvault/shared";
          };
          syncthing = {
            type = "zfs_fs";
            mountpoint = "/zvault/syncthing";
          };
          reserved = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              refreservation = "4T";
            };
          };
        };
      };
    };
  };
}
