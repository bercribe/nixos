{config, ...}: {
  imports = [
    ./default.nix
  ];

  services.reverseProxy = {
    enable = true;
    services.syncthing = {
      port = 8384;
      unique = false;
    };
  };
}
