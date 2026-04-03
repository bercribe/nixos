{
  config,
  local,
  ...
}: let
  utils = local.utils;
  hostKeys = config.local.constants.ssh.host-keys;
in {
  # generate with `ssh-keygen -t ed25519 -N "" -f ./id_ed25519 -C "mawz@<host>"`
  sops.secrets.ssh = {
    owner = "mawz";
    path = "/home/mawz/.ssh/id_ed25519";
    key = "${config.networking.hostName}/ssh";
  };

  programs.ssh.knownHosts =
    builtins.mapAttrs (name: publicKey: {
      extraHostNames = [(utils.hostDomain name)];
      inherit publicKey;
    })
    hostKeys;
}
