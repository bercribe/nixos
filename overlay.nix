{
  nixpkgs-unstable,
  errata,
  ...
}: (final: prev: {
  unstable = import nixpkgs-unstable {
    system = final.system;
  };
  yazi = final.unstable.yazi;
  yaziPlugins =
    final.unstable.yaziPlugins
    // {
      mux = prev.callPackage ./pkgs/yazi/mux.nix {};
    };
  yt-dlp = final.unstable.yt-dlp;

  # TODO: remove
  # version 17.8+ broken on linux - hangs forever on disk read
  makemkv = prev.makemkv.overrideAttrs (p: n: let
    fetchurl = prev.fetchurl;
    lib = prev.lib;
    writeShellApplication = prev.writeShellApplication;
    common-updater-scripts = prev.common-updater-scripts;
    curl = prev.curl;
    rubyPackages = prev.rubyPackages;

    version = "1.17.7";
    # Using two URLs as the first one will break as soon as a new version is released
    src_bin = fetchurl {
      urls = [
        "http://www.makemkv.com/download/makemkv-bin-${version}.tar.gz"
        "http://www.makemkv.com/download/old/makemkv-bin-${version}.tar.gz"
      ];
      hash = "sha256-jFvIMbyVKx+HPMhFDGTjktsLJHm2JtGA8P/JZWaJUdA=";
    };
    src_oss = fetchurl {
      urls = [
        "http://www.makemkv.com/download/makemkv-oss-${version}.tar.gz"
        "http://www.makemkv.com/download/old/makemkv-oss-${version}.tar.gz"
      ];
      hash = "sha256-di5VLUb57HWnxi3LfZfA/Z5qFRINDvb1oIDO4pHToO8=";
    };
  in {
    inherit version;

    srcs = [
      src_bin
      src_oss
    ];

    sourceRoot = "makemkv-oss-${version}";

    installPhase = ''
      runHook preInstall

      install -Dm555 -t $out/bin                              out/makemkv out/mmccextr out/mmgplsrv ../makemkv-bin-${version}/bin/amd64/makemkvcon
      install -D     -t $out/lib                              out/lib{driveio,makemkv,mmbd}.so.*
      install -D     -t $out/share/MakeMKV                    ../makemkv-bin-${version}/src/share/*
      install -Dm444 -t $out/share/applications               ../makemkv-oss-${version}/makemkvgui/share/makemkv.desktop
      install -Dm444 -t $out/share/icons/hicolor/16x16/apps   ../makemkv-oss-${version}/makemkvgui/share/icons/16x16/*
      install -Dm444 -t $out/share/icons/hicolor/32x32/apps   ../makemkv-oss-${version}/makemkvgui/share/icons/32x32/*
      install -Dm444 -t $out/share/icons/hicolor/64x64/apps   ../makemkv-oss-${version}/makemkvgui/share/icons/64x64/*
      install -Dm444 -t $out/share/icons/hicolor/128x128/apps ../makemkv-oss-${version}/makemkvgui/share/icons/128x128/*
      install -Dm444 -t $out/share/icons/hicolor/256x256/apps ../makemkv-oss-${version}/makemkvgui/share/icons/256x256/*

      runHook postInstall
    '';

    passthru = {
      srcs = {
        inherit src_bin src_oss;
      };
      updateScript = lib.getExe (writeShellApplication {
        name = "update-makemkv";
        runtimeInputs = [
          common-updater-scripts
          curl
          rubyPackages.nokogiri
        ];
        text = ''
          get_version() {
            # shellcheck disable=SC2016
            curl --fail --silent 'https://forum.makemkv.com/forum/viewtopic.php?f=3&t=224' \
              | nokogiri -e 'puts $_.css("head title").first.text.match(/\bMakeMKV (\d+\.\d+\.\d+) /)[1]'
          }
          oldVersion=${lib.escapeShellArg version}
          newVersion=$(get_version)
          if [[ $oldVersion == "$newVersion" ]]; then
            echo "$0: New version same as old version, nothing to do." >&2
            exit
          fi
          update-source-version makemkv "$newVersion" --source-key=passthru.srcs.src_bin
          update-source-version makemkv "$newVersion" --source-key=passthru.srcs.src_oss --ignore-same-version
        '';
      });
    };
  });

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
    gtgh = callPackage ./pkgs/scripts/gtgh.nix {};
    sf = callPackage ./pkgs/scripts/sf {};
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
