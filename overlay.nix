{
  nixpkgs-unstable,
  errata,
  ...
}: (final: prev: {
  unstable = import nixpkgs-unstable {
    system = final.system;
  };
  karakeep = final.unstable.karakeep;
  yt-dlp = final.unstable.yt-dlp;

  # user scripts
  errata = errata;

  scripts = with prev; {
    asw = callPackage ./pkgs/scripts/asw.nix {};
    gtgh = callPackage ./pkgs/scripts/gtgh.nix {};
    st = callPackage ./pkgs/scripts/st {};
    tsl = callPackage ./pkgs/scripts/tsl.nix {};
    twl = callPackage ./pkgs/scripts/twl.nix {};
  };

  # local packages
  yaziPlugins =
    prev.yaziPlugins
    // {
      mux = prev.callPackage ./pkgs/yazi/mux.nix {};
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
