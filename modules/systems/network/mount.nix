{config, ...}: let
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
    device = "mawz@192.168.0.43:/mawz-home";
    fsType = "sshfs";
    inherit options;
  };

  fileSystems."/mnt/super-fly" = {
    device = "mawz@192.168.0.51:/zvault";
    fsType = "sshfs";
    inherit options;
  };
}
