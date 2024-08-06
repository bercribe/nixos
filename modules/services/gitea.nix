{config, ...}: {
  # mirroring my repos here with this:
  # https://docs.gitea.com/usage/repo-mirror#pulling-from-a-remote-repository
  services.gitea = {
    enable = true;
    stateDir = "/mnt/mawz-nas/gitea";
    settings = {
      migrations.ALLOWED_DOMAINS = "*.github.com,github.com";
    };
  };
  networking.firewall.allowedTCPPorts = [3000];
}
