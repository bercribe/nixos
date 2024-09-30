{
  self,
  config,
  ...
}: {
  imports = [(self + /modules/sops.nix)];

  sops.secrets.ssh = {
    owner = "mawz";
    path = "/home/mawz/.ssh/id_ed25519";
    key = "${config.networking.hostName}/ssh";
  };

  programs.ssh.knownHosts = {
    mawz-nas = {
      extraHostNames = ["192.168.0.43"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPmljHSvr8veywr2SIWLw8oP0jH75y45KTqROo09yzBk";
    };
    mawz-vault = {
      extraHostNames = ["192.168.0.51"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHKl7hnjyE7BdYQTt7YsHXoqc4/BtUhSArb1c/D+JQVh";
    };
  };
  users.users.mawz.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9n+c6dnlsSg6BQqUuljx5UaUFRO0tz9MbdweCY1m4c" # mawz-fw
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK++5T0hkrduDlpMfdtDh874EqXc4BTPvTzym3chIgHr" # mawz-hue
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF9Wk9adw93SEYRYhiYbP6gonU3TCFtHWDpRYtkipkLc" # mawz-nuc
  ];
}
