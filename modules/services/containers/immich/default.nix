{pkgs, ...}: {
  # Enable docker
  virtualisation.docker.enable = true;
  users.users.mawz.extraGroups = ["docker"];

  # upgrading: `docker compose pull` and update version in .env
  systemd.services.immich = {
    script = ''
      cd ${./.}
      ${pkgs.docker}/bin/docker compose up -d
    '';
    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 60;
    };
  };

  networking.firewall.allowedTCPPorts = [80];
  services.caddy = {
    enable = true;
    virtualHosts."http://immich.lan".extraConfig = ''
      reverse_proxy localhost:2283
    '';
  };
}
