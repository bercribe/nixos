{
  nixpkgs-unstable,
  errata,
  karatui,
  ...
}: [
  errata.overlays.default

  (final: prev: let
    unstablePackages = [
      "amdtop"
      "devenv"
      "gallery-dl"
      "ghgrab"
      "glab-tui"
      "karakeep"
      "lazyrsync"
      "makemkv"
      "nono"
      "pi-coding-agent"
      "pocket-tts"
      "whosthere"
    ];
    unstableOverlay = builtins.listToAttrs (map (package: {
        name = package;
        value = final.unstable.${package};
      })
      unstablePackages);
  in
    {
      unstable = import nixpkgs-unstable {
        inherit (final.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    }
    // unstableOverlay)

  (final: prev: {
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
