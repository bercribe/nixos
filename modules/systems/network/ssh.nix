{
  self,
  config,
  ...
}: {
  programs.ssh.knownHosts = {
    mawz-hue = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK++5T0hkrduDlpMfdtDh874EqXc4BTPvTzym3chIgHr";
    };
    mawz-nas = {
      extraHostNames = ["192.168.0.43"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPmljHSvr8veywr2SIWLw8oP0jH75y45KTqROo09yzBk";
    };
  };
}
