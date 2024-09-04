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

  programs.ssh.knownHosts.mawz-nas = {
    extraHostNames = ["192.168.0.43"];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPmljHSvr8veywr2SIWLw8oP0jH75y45KTqROo09yzBk";
  };

  # Requires SFTP to be enabled
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
