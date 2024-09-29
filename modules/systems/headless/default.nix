{
  self,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../common.nix
    (self + /modules/systems/network/ssh.nix)
  ];

  # Programs

  # necessary for vscode remote ssh
  programs.nix-ld.enable = true;

  # Services

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  users.users.mawz.openssh.authorizedKeys.keys = builtins.catAttrs "publicKey" (builtins.attrValues config.programs.ssh.knownHosts);
}
