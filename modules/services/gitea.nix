{
  config,
  pkgs,
  ...
}: let
  port = 12552;
in {
  imports = [../systems/network/mawz-nas-ssh.nix];

  # mirroring my repos here with this:
  # https://docs.gitea.com/usage/repo-mirror#pulling-from-a-remote-repository
  services.gitea = {
    enable = true;
    settings = {
      server.HTTP_PORT = port;
      migrations.ALLOWED_DOMAINS = "*.github.com,github.com";
    };
  };
  networking.firewall.allowedTCPPorts = [port];

  systemd.timers.gitea-backup = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "gitea-backup.service";
    };
  };
  systemd.services.gitea-backup = {
    script = let
      identityFile = config.sops.secrets."mawz-nas/ssh/private".path;
    in ''
      ${pkgs.rsync}/bin/rsync -az --delete -e "${pkgs.openssh}/bin/ssh -i ${identityFile}" ${config.services.gitea.stateDir} mawz@192.168.0.43:/volume1/mawz-home/gitea/
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    # prevents backup from being clobbered on a new system install
    # to restore backup, run
    # sudo cp <backup> /var/lib/gitea
    # sudo chown -R gitea:gitea /var/lib/gitea
    unitConfig.AssertPathExists = "/backups/config/gitea";
  };
}
