{
  self,
  pkgs,
  config,
  lib,
  ...
}: let
  resticJobs = ["synology-nas" "backblaze"];
in {
  # ZFS snapshots and replication
  services.sanoid = {
    enable = true;
    templates.default = {
      autosnap = true;
      autoprune = true;
      hourly = 36;
      daily = 30;
      monthly = 3;
    };
    datasets = {
      zvault = {
        useTemplate = ["default"];
        # don't want to include zvault/hosts here, syncoid already takes care of snapshots.
        # enabling with sanoid can cause syncoid to fail to upload a snapshot because sanoid has already created one with the same name
        recursive = false;
      };
      "zvault/syncthing" = {
        useTemplate = ["default"];
        recursive = true;
      };
    };
  };

  sops.secrets.syncoid-ssh = {
    owner = config.services.syncoid.user;
    key = "${config.networking.hostName}/ssh";
  };
  # on remote machine, need to run `zfs allow -u mawz-vault send,hold,mount,snapshot,destroy <ds>`
  # https://github.com/jimsalterjrs/sanoid/wiki/Syncoid#running-without-root
  services.syncoid = let
    hostName = config.networking.hostName;
  in {
    enable = true;
    sshKey = config.sops.secrets.syncoid-ssh.path;
    commands = {
      mawz-nuc = {
        recursive = true;
        source = "${hostName}@mawz-nuc.lan:zpool/services";
        target = "zvault/hosts/mawz-nuc";
        service = {
          onSuccess = ["mawz-nuc-syncoid-notify.service"];
        };
      };
    };
  };

  # Restic offsite backups
  sops.secrets.restic-repo = {};
  sops.secrets."backblaze/envVars" = {};

  services.restic.backups = let
    dataset = "zvault";
    baseBackupPath = "/tmp/restic-snapshot";

    defaultOpts = job: let
      backupPath = "${baseBackupPath}/${job}";
      zfsCommand = "${pkgs.zfs}/bin/zfs";
    in {
      initialize = true;
      createWrapper = true;
      runCheck = true;
      passwordFile = config.sops.secrets.restic-repo.path;
      paths = [
        backupPath
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 75"
      ];

      backupPrepareCommand = ''
        # for each dataset recursively
        for ds in $(${zfsCommand} list -r -H -o name -s name ${dataset}); do
          # get latest snapshot
          snapshot=$(${zfsCommand} list -t snap -H -o name -s creation "$ds" | tail -1)

          mkdir -p "${backupPath}/$ds"
          ${pkgs.util-linux}/bin/mount -t zfs "$snapshot" "${backupPath}/$ds"
        done
        echo "### Mounted Snapshots ###"
      '';
      backupCleanupCommand = ''
        for ds in $(${zfsCommand} list -r -H -o name -S name ${dataset}); do
          ${pkgs.util-linux}/bin/umount -t zfs "${backupPath}/$ds"
        done
        echo "### Unmounted Snapshots ###"
        rm -r ${backupPath}
      '';
    };

    jobOpts = {
      synology-nas = {
        repository = "sftp:mawz@192.168.0.43:/mawz-home/backups/${config.networking.hostName}";
        extraOptions = [
          "sftp.args='-i ${config.sops.secrets.ssh.path}'"
        ];
      };
      backblaze = {
        repository = "s3.us-west-000.backblazeb2.com/mawz-vault-backup";
        environmentFile = config.sops.secrets."backblaze/envVars".path;
      };
    };

    opts = with lib; listToAttrs (map (job: nameValuePair job ((defaultOpts job) // jobOpts."${job}")) resticJobs);
  in
    opts;

  systemd.services = let
    opts = with lib;
      (listToAttrs ((map (job:
          nameValuePair "restic-backups-${job}" {
            serviceConfig = {
              # interferes with zfs mount between stages
              PrivateTmp = lib.mkForce false;
            };
            onSuccess = ["${job}-restic-notify.service"];
          })
        resticJobs)
        ++ (map (job:
          nameValuePair "${job}-restic-notify" {
            script = ''
              pingKey="$(cat ${config.sops.secrets."healthchecks/local/ping-key".path})"
              ${pkgs.curl}/bin/curl -m 10 --retry 5 --retry-connrefused "http://healthchecks.lan/ping/$pingKey/${job}-restic-backup"
            '';
            serviceConfig = {
              Type = "oneshot";
              User = "root";
            };
          })
        resticJobs)))
      // {
        mawz-nuc-syncoid-notify = {
          script = ''
            pingKey="$(cat ${config.sops.secrets."healthchecks/local/ping-key".path})"
            ${pkgs.curl}/bin/curl -m 10 --retry 5 --retry-connrefused "http://healthchecks.lan/ping/$pingKey/mawz-nuc-syncoid-backup"
          '';
          serviceConfig = {
            Type = "oneshot";
            User = "root";
          };
        };
      };
  in
    opts;
}
