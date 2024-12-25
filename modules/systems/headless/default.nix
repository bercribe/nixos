{
  self,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../common.nix
    (self + /modules/systems/network/ssh-server.nix)
  ];

  # Secrets
  sops.secrets = {
    ssh-host = {
      path = "/etc/ssh/ssh_host_ed25519_key";
      key = "${config.networking.hostName}/ssh-host";
    };
  };

  # User env

  environment.systemPackages = with pkgs; [
    lzop # compression with syncoid
    mbuffer # buffering with syncoid
  ];

  # Programs

  # necessary for vscode remote ssh
  programs.nix-ld.enable = true;

  # Enable mosh, the ssh alternative when client has bad connection
  # Opens UDP ports 60000 ... 61000
  programs.mosh.enable = true;

  # Services
  network.sshServer = {
    enableOpenssh = true;
    createHostUsers = true;
  };
}
