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
    };
    # fixes https://github.com/microvm-nix/microvm.nix/pull/477#issuecomment-4122489542
    cloud-hypervisor = final.unstable.cloud-hypervisor;
    devenv = final.unstable.devenv;
    karakeep = final.unstable.karakeep;
    pi-coding-agent = final.unstable.pi-coding-agent;
    whosthere = final.unstable.whosthere;
    yt-dlp = final.unstable.yt-dlp;

    # personal-packages
    karatui = karatui.packages.${final.stdenv.hostPlatform.system}.default;

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
]
