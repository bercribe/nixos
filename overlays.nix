{
  nixpkgs-unstable,
  errata,
  ...
}: [
  (final: prev: {
    unstable = import nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };

    # TODO: remove
    # https://github.com/hrkfdn/ncspot/issues/1681
    ncspot = prev.ncspot.overrideAttrs (pfinal: pprev: {
      version = "1.3.0";
      src = prev.fetchFromGitHub {
        owner = "bluware-dev";
        repo = "ncspot";
        rev = "aac67d631f25bbc79f509d34aa85e6daff954830";
        hash = "sha256-B6BA1ksfDEySZH6gzkU5khOzwXAmeHbMHsx3sXd9lbs=";
      };
      cargoDeps = prev.rustPlatform.importCargoLock {
        lockFile = pfinal.src + "/Cargo.lock";
        allowBuiltinFetchGit = true;
      };
      cargoHash = null;
    });

    # TODO: remove
    # https://github.com/NixOS/nixpkgs/issues/401010
    healthchecks = let
      inherit (prev) lib;
      # https://discourse.nixos.org/t/python-possible-to-override-packageoverrides/63855/3
      preservePython3PackageOverrides = p:
        p
        // {
          override = lib.mirrorFunctionArgs p.override (
            fdrv:
              preservePython3PackageOverrides (
                p.override (
                  previous: let
                    fdrv' = lib.toFunction fdrv previous;
                  in
                    fdrv'
                    // lib.optionalAttrs (fdrv' ? python3) {
                      python3 =
                        fdrv'.python3
                        // {
                          override = lib.mirrorFunctionArgs fdrv'.python3.override (
                            fdrv:
                              fdrv'.python3.override (
                                previous: let
                                  fdrv' = lib.toFunction fdrv previous;
                                in
                                  fdrv'
                                  // {
                                    packageOverrides =
                                      lib.composeExtensions previous.packageOverrides or (_: _: {})
                                      fdrv'.packageOverrides or (_: _: {});
                                  }
                              )
                          );
                        };
                    }
                )
              )
          );
        };
      python = let
        packageOverrides = pyfinal: pyprev: {
          pydantic = pyprev.pydantic.overridePythonAttrs rec {
            version = "2.11.4";
            src = prev.fetchFromGitHub {
              owner = "pydantic";
              repo = "pydantic";
              tag = "v${version}";
              hash = "sha256-/LMemrO01KnhDrqKbH1qBVyO/uAiqTh5+FHnrxE8BUo=";
            };
          };
          pydantic-core = pyprev.pydantic-core.overridePythonAttrs (old: rec {
            version = "2.33.2";
            src = prev.fetchFromGitHub {
              owner = "pydantic";
              repo = "pydantic-core";
              tag = "v${version}";
              hash = "sha256-2jUkd/Y92Iuq/A31cevqjZK4bCOp+AEC/MAnHSt2HLY=";
            };
            cargoDeps = prev.rustPlatform.fetchCargoVendor {
              inherit src;
              name = "pydantic-core-2.33.2";
              hash = "sha256-MY6Gxoz5Q7nCptR+zvdABh2agfbpqOtfTtor4pmkb9c=";
            };
          });
        };
      in
        prev.python3.override {
          self = python;
          inherit packageOverrides;
        };
    in
      (preservePython3PackageOverrides prev.healthchecks).override {
        python3 = python;
      };

    # user scripts
    errata = errata;

    scripts = with prev; {
      asw = callPackage ./pkgs/scripts/asw.nix {};
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
