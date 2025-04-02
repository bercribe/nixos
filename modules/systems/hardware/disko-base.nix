{
  config,
  lib,
  ...
}: let
  cfg = config.local.disko;
in {
  options.local.disko = with lib;
  with types; {
    device = mkOption {
      type = str;
      description = "Device to use as main disk";
    };
    zpoolName = mkOption {
      type = str;
      default = "zroot";
      description = "Name of the root zpool";
    };
    extraRootDatasets = mkOption {
      type = listOf str;
      default = [];
      description = "Extra datasets to create at the root directory";
    };
    enableEncryption = mkEnableOption "encryption";
    spaceReserved = mkOption {
      type = str;
      description = "Amount of space to reserve in zpool";
    };
  };

  config.disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = cfg.device;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            swap = {
              size = "4G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = cfg.zpoolName;
              };
            };
          };
        };
      };
    };
    zpool = {
      "${cfg.zpoolName}" = {
        type = "zpool";
        rootFsOptions =
          {
            # https://wiki.archlinux.org/title/Install_Arch_Linux_on_ZFS
            acltype = "posixacl";
            atime = "off";
            compression = "lz4";
            mountpoint = "none";
            xattr = "sa";
          }
          // lib.optionalAttrs cfg.enableEncryption {
            encryption = "on";
            keyformat = "passphrase";
            keylocation = "prompt";
          };
        options.ashift = "12";

        datasets = let
          extraDatasets = with lib;
            listToAttrs (map (dataset:
              nameValuePair dataset {
                type = "zfs_fs";
                mountpoint = "/${dataset}";
              })
            cfg.extraRootDatasets);
        in
          {
            root = {
              type = "zfs_fs";
              mountpoint = "/";
            };
            nix = {
              type = "zfs_fs";
              mountpoint = "/nix";
            };
            home = {
              type = "zfs_fs";
              mountpoint = "/home";
            };
            reserved = {
              type = "zfs_fs";
              options = {
                mountpoint = "none";
                refreservation = cfg.spaceReserved;
              };
            };
          }
          // extraDatasets;
      };
    };
  };
}
