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
    makeVarDataset = mkOption {
      type = bool;
      default = false;
      description = "True to make a directory for the /var directory";
    };
    makeServicesDataset = mkOption {
      type = bool;
      default = false;
      description = "True to make a directory for the /services directory";
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

        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
          var = lib.mkIf cfg.makeVarDataset {
            type = "zfs_fs";
            mountpoint = "/var";
          };
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
          };
          services = lib.mkIf cfg.makeServicesDataset {
            type = "zfs_fs";
            mountpoint = "/services";
          };
          reserved = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              refreservation = cfg.spaceReserved;
            };
          };
        };
      };
    };
  };
}
