{config, ...}: {
  imports = [./ssh.nix];

  # Requires SFTP to be enabled
  fileSystems."/mnt/mawz-nas" = {
    device = "mawz@192.168.0.43:/mawz-home";
    fsType = "sshfs";
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
  };
}
