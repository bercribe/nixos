{
  nixpkgs-unstable,
  errata,
  karatui,
  ...
}: [
  errata.overlays.default
  (final: prev: {
    unstable = import nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
    devenv = final.unstable.devenv;
    gallery-dl = final.unstable.gallery-dl;
    ghgrab = final.unstable.ghgrab;
    glab-tui = final.unstable.glab-tui;
    karakeep = final.unstable.karakeep;
    lazyrsync = final.unstable.lazyrsync;
    makemkv = final.unstable.makemkv;
    nono = final.unstable.nono;
    pi-coding-agent = final.unstable.pi-coding-agent;
    pocket-tts = final.unstable.pocket-tts;
    whosthere = final.unstable.whosthere;

    yt-dlp = final.unstable.yt-dlp.overrideAttrs (prev: rec {
      version = "2026.08.19";
      src = prev.src.override {
        tag = version;
        hash = "sha256-BM5ZeGTmHq+1xH6G/zsuCtjLgYgfRA11ya0zIHK5p4g=";
      };
    });

    # personal-packages
    karatui = karatui.packages.${final.stdenv.hostPlatform.system}.default;

    # local packages
    yaziPlugins =
      prev.yaziPlugins
      // {
        mux = final.callPackage ./pkgs/yazi/mux.nix {};
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
]
