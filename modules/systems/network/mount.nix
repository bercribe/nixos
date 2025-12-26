{
  config,
  local,
  ...
}: let
  utils = local.utils;
  options = [
    "nodev"
    "noatime"
    "allow_other"
    "IdentityFile=${config.sops.secrets.ssh.path}"
    # for reconnecting after suspend
    "reconnect"
    "ServerAliveInterval=15"
    "ServerAliveCountMax=3"
    "x-systemd.automount" # mount on demand
  ];
in {
  imports = [./ssh-client.nix];

  # Requires SFTP to be enabled
  fileSystems."/mnt/mr-president" = {
    device = "mawz@${utils.hostDomain "mr-president"}:/mawz-home";
    fsType = "sshfs";
    inherit options;
  };

  fileSystems."/mnt/super-fly" = {
    device = "mawz@${utils.hostDomain "super-fly"}:/zvault";
    fsType = "sshfs";
    inherit options;
  };
}
