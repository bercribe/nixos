{config, ...}: {
  # generate with `ssh-keygen -t ed25519 -N "" -f ./id_ed25519 -C "mawz@<host>"`
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
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMNTo4tnqG7zk+yAmA7JUOapVjhSWkhdqSoEor9q+KbL";
    };
    moody-blues = {
      extraHostNames = ["moody-blues.mawz.dev"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBUCKXB7muqmoovAblrX2znV3PUejkIqqZ4OxSMGuXGE";
    };
    super-fly = {
      extraHostNames = ["super-fly.mawz.dev"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdZUinVNS9d3LOmDKYWq4kEb6iO1uKaJOGhBZ4cQ6/h";
    };
  };
}
