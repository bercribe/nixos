{...}: let
  port = 8096;
  dataDir = "/services/jellyfin";
in {
  services.jellyfin = {
    enable = true;
    inherit dataDir;
  };

  services.reverseProxy = {
    enable = true;
    services.jellyfin = {
      inherit port;
    };
  };
}
