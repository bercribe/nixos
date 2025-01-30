{config, ...}: {
  imports = [
    ./default.nix
  ];

  local.reverseProxy = {
    enable = true;
    services.syncthing = {
      port = 8384;
      unique = false;
    };
  };
}
