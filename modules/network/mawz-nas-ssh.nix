{
  config,
  sops-nix,
  ...
}: {
  imports = [sops-nix.nixosModules.sops];

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
}
