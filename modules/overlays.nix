{
  config,
  pkgs,
  nixpkgs-unstable,
  typst-live,
  ...
}: {
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import nixpkgs-unstable {
        system = final.system;
        config.allowUnfree = true;
      };

      # https://github.com/NixOS/nixpkgs/pull/338957
      ffsubsync = prev.ffsubsync.overrideAttrs (prev: {
        propagatedBuildInputs = prev.propagatedBuildInputs ++ [final.pkgs.ffmpeg final.python3.pkgs.setuptools];
      });

      # prevent file browser from hijacking default FileChooser status
      thunar = prev.xfce.thunar.overrideAttrs (prev: {
        postFixup = ''
          rm -r $out/share/dbus-1
        '';
      });

      typst-live = typst-live.packages."${final.system}".default;
    })
  ];
}
