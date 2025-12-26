{
  pkgs,
  config,
  lib,
  local,
  ...
}: let
  sanoidHosts = ["heavens-door" "highway-star" "judgement" "moody-blues" "super-fly"];
  syncoidJobs = ["judgement" "moody-blues" "super-fly"];
  resticJobs = ["mr-president" "backblaze"];

  utils = local.utils;
in {
  local.cron.echoes-backup.enable = true;
  local.cron.gdrive-backup.enable = true;

  # ZFS snapshots and replication
  services.sanoid = {
    enable = true;
    templates = let
      defaults = {
        autosnap = true;
        autoprune = true;
        hourly = 36;
        daily = 30;
        monthly = 3;
      };
    in {
      default = defaults;
      host =
        defaults
        // {
          autosnap = false;
        };
    };
    datasets = let
      # prevent taking snapshots on datasets managed by syncoid.
      # enabling with sanoid can cause syncoid to fail to upload a snapshot because sanoid has already created one with the same name
      hostConfigs = with lib; listToAttrs (map (hostName: nameValuePair "zvault/hosts/${hostName}" {useTemplate = ["host"];}) sanoidHosts);
    in
      {
        zvault = {
          useTemplate = ["default"];
          recursive = true;
        };
      }
      // hostConfigs;
  };

  sops.secrets.syncoid-ssh = {
    owner = config.services.syncoid.user;
    key = "${config.networking.hostName}/ssh";
  };
  # on remote machine, need to run `zfs allow -u super-fly send,hold,mount,snapshot,destroy <ds>`
  # remember to update sanoid rules!
  # https://github.com/jimsalterjrs/sanoid/wiki/Syncoid#running-without-root
  services.syncoid = let
    hostName = config.networking.hostName;

    defaultOpts = job: {
      recursive = true;
      target = "zvault/hosts/${job}";
      service = {
        onSuccess = ["${job}-syncoid-notify.service"];
      };
    };
    jobOpts = {
      judgement = {
        source = "${hostName}@${utils.hostDomain "judgement"}:zpool/services";
      };
      moody-blues = {
        source = "${hostName}@${utils.hostDomain "moody-blues"}:zroot/services";
      };
      super-fly = {
        source = "${
          if config.local ? disko.zpoolName
          then config.local.disko.zpoolName
          else "zpool"
        }/services";
      };
    };

    commands = with lib; listToAttrs (map (job: (nameValuePair job ((defaultOpts job) // jobOpts."${job}"))) syncoidJobs);
  in {
    enable = true;
    sshKey = config.sops.secrets.syncoid-ssh.path;
    inherit commands;
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
      # would be nice to get rid of the /tmp/restic-snapshot in the backup
      # https://github.com/restic/restic/issues/2092
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
        set -eo

        # for each dataset recursively
        for ds in $(${zfsCommand} list -r -H -o name -s name ${dataset}); do
          # get latest snapshot
          snapshot=$(${zfsCommand} list -t snap -H -o name -s creation "$ds" | tail -1)
          mountpoint=$(${zfsCommand} list -H -o mountpoint "$ds")

          if [ "$mountpoint" != "none" ]; then
            command="${pkgs.util-linux}/bin/mount -t zfs -m $snapshot ${backupPath}/$ds"
            echo "running '$command'"
            $command
          fi
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
      mr-president = {
        # setting up host:
        # ssh -a super-fly
        # ssh-keygen -f ~/.ssh/id_ed25519 -y > ~/.ssh/id_ed25519.pub
        # ssh-copy-id mr-president
        repository = "sftp:mawz@${utils.hostDomain "mr-president"}:/mawz-home/backups/${config.networking.hostName}";
        extraOptions = [
          "sftp.args='-i ${config.sops.secrets.ssh.path}'"
        ];
        timerConfig = {
          OnCalendar = "01:00";
          Persistent = true;
        };
      };
      backblaze = {
        repository = "s3:s3.us-west-000.backblazeb2.com/super-fly-backup/restic";
        environmentFile = config.sops.secrets."backblaze/envVars".path;
        timerConfig = {
          OnCalendar = "13:00";
          Persistent = true;
        };
      };
    };

    opts = with lib; listToAttrs (map (job: nameValuePair job ((defaultOpts job) // jobOpts."${job}")) resticJobs);
  in
    opts;

  systemd.services = let
    opts = with lib; (listToAttrs (
      (map (job:
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
            ${utils.writeHealthchecksPingScript {slug = "${job}-restic-backup";}}
          '';
          serviceConfig = {
            Type = "oneshot";
            User = "root";
          };
        })
      resticJobs)
      ++ (map (job:
        nameValuePair "${job}-syncoid-notify" {
          script = ''
            ${utils.writeHealthchecksPingScript {slug = "${job}-syncoid-backup";}}
          '';
          serviceConfig = {
            Type = "oneshot";
            User = "root";
          };
        })
      syncoidJobs)
    ));
  in
    opts;
}
