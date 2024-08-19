{pkgs, ...}: {
  # upgrading: `docker compose pull` and update version in .env
  systemd.services.immich = {
    script = ''
      cd ${./.}
      ${pkgs.docker}/bin/docker compose up -d
    '';
    wantedBy = ["multi-user.target" "mnt-mawz\\x2dnas.mount"];
    after = ["docker.service" "docker.socket"];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 60;
    };
  };
}
