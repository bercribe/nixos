{lib, ...}: let
  defaultApps = {
    directory = "yazi.desktop";
    browser = "firefox.desktop";
    text = "nvim.desktop";
    image = "imv.desktop";
    video = "mpv.desktop";
    pdf = "org.pwmt.zathura-pdf-mupdf.desktop";
  };

  mimeMap = {
    directory = [
      "inode/directory"
    ];
    browser = [
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
    text = [
      "text/plain"
      "text/x-python"
    ];
    image = [
      "image/jpeg"
      "image/png"
      "image/svg+xml"
      "image/webp"
    ];
    video = [
      "audio/vnd.wave"
      "video/mp4"
      "video/vnd.avi"
      "video/x-matroska"
    ];
    pdf = [
      "application/pdf"
    ];
  };

  associations = with lib;
    listToAttrs (concatLists (mapAttrsToList (key:
      map (type: nameValuePair type defaultApps."${key}"))
    mimeMap));
in {inherit associations;}
