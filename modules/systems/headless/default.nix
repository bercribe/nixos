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

  # Enable mosh, the ssh alternative when client has bad connection
  # Opens UDP ports 60000 ... 61000
  programs.mosh.enable = true;

  # Services

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
}
