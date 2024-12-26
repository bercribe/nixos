{
  self,
  config,
  pkgs,
  ...
}: let
  port = 12552;
in {
  imports = [
    (self + /modules/clients/local-healthchecks.nix)
  ];

  # mirroring my repos here with this:
  # https://docs.gitea.com/usage/repo-mirror#pulling-from-a-remote-repository
  services.gitea = {
    enable = true;
    stateDir = "/services/gitea";
    settings = {
      server.HTTP_PORT = port;
      migrations.ALLOWED_DOMAINS = "*.github.com,github.com";
    };
  };

  networking.firewall.allowedTCPPorts = [80 port];
  services.caddy = {
    enable = true;
    virtualHosts."http://gitea.lan".extraConfig = ''
      reverse_proxy localhost:${toString port}
    '';
  };
}
