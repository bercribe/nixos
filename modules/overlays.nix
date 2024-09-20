{
  config,
  pkgs,
  nixpkgs-unstable,
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

      # prevent dolphin from hijacking default FileChooser status
      dolphin = prev.libsForQt5.dolphin.overrideAttrs (prev: {
        postFixup = ''
          rm -r $out/share/dbus-1
        '';
      });
    })
  ];
}
