{
  imports = [../../modules/systems/hardware/disko-base.nix];

  local.disko = {
    device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S7KHNU0X515561Z";
    zpoolName = "zpool";
    makeVarDataset = true;
    enableEncryption = true;
    spaceReserved = "300G";
  };

  disko.devices = {
    disk = {
      solid = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_4TB_S757NS0X802097A";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zsolid";
              };
            };
          };
        };
      };
      rust = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD4005FZBX-00K5WB0_VBG3Z2YR";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zrust";
              };
            };
          };
        };
      };
    };
    zpool = let
      rootFsOptions = {
        # https://wiki.archlinux.org/title/Install_Arch_Linux_on_ZFS
        acltype = "posixacl";
        atime = "off";
        compression = "lz4";
        mountpoint = "none";
        xattr = "sa";
        encryption = "on";
        keyformat = "passphrase";
        keylocation = "file:///run/secrets/zfs-drive";
      };
    in {
      zsolid = {
        type = "zpool";
        inherit rootFsOptions;
        options.ashift = "12";
        mountpoint = "/zsolid";

        datasets = {
          games = {
            type = "zfs_fs";
            mountpoint = "/zsolid/games";
          };
          syncthing = {
            type = "zfs_fs";
            mountpoint = "/zsolid/syncthing";
          };
          reserved = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              refreservation = "600G";
            };
          };
        };
      };
      zrust = {
        type = "zpool";
        rootFsOptions =
          rootFsOptions
          // {
            compression = "zstd";
          };
        options.ashift = "12";
        mountpoint = "/zrust";

        datasets = {
          reserved = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              refreservation = "600G";
            };
          };
        };
      };
    };
  };
}
