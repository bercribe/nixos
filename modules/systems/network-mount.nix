{
  config,
  sops,
  ...
}: {
  # Secrets management
  sops = {
    # update this with `sops secrets.yaml`
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/mawz/.config/sops/age/keys.txt";
    secrets."mawz-nas/ssh/private" = {};
  };

  # Requires SFTP to be enabled
  # Have to run:
  # `sudo sshfs -o IdentityFile=/run/secrets/mawz-nas/ssh/private mawz@192.168.0.43:/mawz-home <tmpdir>`
  # and say "yes" to the prompt the first time.
  # Then run `sudo fusermount -u <tmpdir>`
  fileSystems."/mnt/mawz-nas" = {
    device = "mawz@192.168.0.43:/mawz-home";
    fsType = "sshfs";
    options = [
      "nodev"
      "noatime"
      "allow_other"
      "IdentityFile=${config.sops.secrets."mawz-nas/ssh/private".path}"
      # for reconnecting after suspend
      "reconnect"
      "ServerAliveInterval=15"
      "ServerAliveCountMax=3"
      "x-systemd.automount" # mount on demand
    ];
  };
}
