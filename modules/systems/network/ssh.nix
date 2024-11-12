{
  self,
  config,
  ...
}: let
  mawzFwKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9n+c6dnlsSg6BQqUuljx5UaUFRO0tz9MbdweCY1m4c";
  mawzHueKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK++5T0hkrduDlpMfdtDh874EqXc4BTPvTzym3chIgHr";
  mawzNucKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF9Wk9adw93SEYRYhiYbP6gonU3TCFtHWDpRYtkipkLc";
  mawzVaultKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXbugt7AceFpzb4ftHnCRHW7TpTbp7S2cqzHcXJlvH1";
in {
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
      extraHostNames = ["mawz-vault.lan" "192.168.0.51"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHKl7hnjyE7BdYQTt7YsHXoqc4/BtUhSArb1c/D+JQVh";
    };
  };

  users.groups.hosts = {};
  users.users.mawz-fw = {
    isNormalUser = true;
    group = "hosts";
    openssh.authorizedKeys.keys = [mawzFwKey];
  };
  users.users.mawz-hue = {
    isNormalUser = true;
    group = "hosts";
    openssh.authorizedKeys.keys = [mawzHueKey];
  };
  users.users.mawz-nuc = {
    isNormalUser = true;
    group = "hosts";
    openssh.authorizedKeys.keys = [mawzNucKey];
  };
  users.users.mawz-vault = {
    isNormalUser = true;
    group = "hosts";
    openssh.authorizedKeys.keys = [mawzVaultKey];
  };
  users.users.mawz.openssh.authorizedKeys.keys = [mawzFwKey mawzHueKey mawzNucKey mawzVaultKey];
}
