{
  self,
  config,
  ...
}: {
  # generate with `ssh-keygen -t ed25519 -N "" -f ./id_ed25519 -C "<email>"`
  sops.secrets.ssh = {
    owner = "mawz";
    path = "/home/mawz/.ssh/id_ed25519";
    key = "${config.networking.hostName}/ssh";
  };

  # get public key: `sudo ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -y`
  programs.ssh.knownHosts = {
    mr-president = {
      extraHostNames = ["mr-president.mawz.dev"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPmljHSvr8veywr2SIWLw8oP0jH75y45KTqROo09yzBk";
    };
    judgement = {
      extraHostNames = ["judgement.mawz.dev"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJOW1O35VwVbx68SB6THn1M0bZPqBM4Y6Lk6+wFcdi1n";
    };
    moody-blues = {
      extraHostNames = ["moody-blues.mawz.dev"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2J4BJItsn/t6M8q7Zpi7B6YDpznItrHweLZ2WfppbF";
    };
    super-fly = {
      extraHostNames = ["super-fly.mawz.dev"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHKl7hnjyE7BdYQTt7YsHXoqc4/BtUhSArb1c/D+JQVh";
    };
  };
}
