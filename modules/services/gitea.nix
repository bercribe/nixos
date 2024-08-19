{config, ...}: let
  port = 12552;
in {
  # mirroring my repos here with this:
  # https://docs.gitea.com/usage/repo-mirror#pulling-from-a-remote-repository
  services.gitea = {
    enable = true;
    stateDir = "/mnt/mawz-nas/gitea";
    settings = {
      server.HTTP_PORT = port;
      migrations.ALLOWED_DOMAINS = "*.github.com,github.com";
    };
  };
  networking.firewall.allowedTCPPorts = [port];
  systemd.services.gitea = {
    wantedBy = ["mnt-mawz\\x2dnas.mount"];
    serviceConfig = {
      RestartSec = 60;
    };
  };
}
