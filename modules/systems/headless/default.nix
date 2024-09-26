{
  self,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../common.nix
  ];

  # Programs

  # necessary for vscode remote ssh
  programs.nix-ld.enable = true;

  # Services

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
}
