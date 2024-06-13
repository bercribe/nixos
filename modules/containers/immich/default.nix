{pkgs, ...}: {
  systemd.services.immich = {
    script = ''
      cd ${./.}
      ${pkgs.docker}/bin/docker compose up -d
    '';
    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
  };
}
