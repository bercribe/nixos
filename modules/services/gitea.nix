{config, ...}: {
  services.gitea = {
    enable = true;
    stateDir = "/mnt/mawz-nas/gitea";
    settings = {
      migrations.ALLOWED_DOMAINS = "*.github.com,github.com";
    };
  };
  networking.firewall.allowedTCPPorts = [3000];
}
