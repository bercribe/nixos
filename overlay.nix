{
  nixpkgs-unstable,
  errata,
  ...
}: (final: prev: {
  unstable = import nixpkgs-unstable {
    system = final.system;
  };
  home-assistant = final.unstable.home-assistant;
  home-assistant-custom-components = final.unstable.home-assistant-custom-components;
  immich = final.unstable.immich;
  yaziPlugins =
    prev.yaziPlugins
    // {
      mux = prev.callPackage ./pkgs/yazi/mux.nix {};
    };
  yt-dlp = final.unstable.yt-dlp;

  # user scripts
  errata = errata;

  scripts = with prev; {
    asw = callPackage ./pkgs/scripts/asw.nix {};
    gtgh = callPackage ./pkgs/scripts/gtgh.nix {};
    sf = callPackage ./pkgs/scripts/sf {};
    tsl = callPackage ./pkgs/scripts/tsl.nix {};
    twl = callPackage ./pkgs/scripts/twl.nix {};
  };

  # album art - currently broken
  # ncspot = prev.ncspot.override (prev: {
  #   withCover = true;
  # });

  # fixes fcitx5 in obsidian
  # https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland#Chromium_.2F_Electron
  obsidian = prev.obsidian.overrideAttrs (prev: {
    postFixup = ''
      wrapProgram $out/bin/obsidian \
        --add-flags "--enable-wayland-ime"
    '';
  });

  # prevent file browser from hijacking default FileChooser status
  thunar = prev.xfce.thunar.overrideAttrs (prev: {
    postFixup = ''
      rm -r $out/share/dbus-1
    '';
  });

  waybar = prev.waybar.override (prev: {
    withMediaPlayer = true;
  });
})
