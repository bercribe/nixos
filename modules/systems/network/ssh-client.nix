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
    judgement = {
      extraHostNames = ["judgement.lan" "192.168.0.54"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJOW1O35VwVbx68SB6THn1M0bZPqBM4Y6Lk6+wFcdi1n";
    };
    super-fly = {
      extraHostNames = ["super-fly.lan" "192.168.0.51"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHKl7hnjyE7BdYQTt7YsHXoqc4/BtUhSArb1c/D+JQVh";
    };
  };
}
