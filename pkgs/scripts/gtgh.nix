{
  pkgs,
  lib,
  ...
}: let
  git = lib.getExe pkgs.git;
in
  pkgs.writeShellScriptBin "gtgh" ''
    # gtgh.sh - goto github

    url=$(${git} remote get-url origin)
    if [[ ! $url =~ http ]]; then # assume ssh form
      url=$(echo "$url" | sed -E 's|.*git@(.*?):|https://\1/|')
    fi

    xdg-open "$url"
  ''
