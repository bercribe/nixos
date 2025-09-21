{
  pkgs,
  lib,
  ...
}: let
  git = lib.getExe pkgs.git;
in
  pkgs.writeShellScriptBin "gtgh" ''
    # gtgh.sh - goto github
    # usage: provide file path in first arg and line number in second arg

    path=$1
    lineNum=$2

    if [[ -f $path ]]; then
      abspath=$(realpath "$path")
      pushd "$(dirname "$path")" 1>/dev/null
    elif [[ -d $path ]]; then
      pushd "$path" 1>/dev/null
    else
      pushd . 1>/dev/null
    fi

    url=$(${git} remote get-url origin)
    if [[ ! $url =~ http ]]; then # assume ssh form
      url=$(echo "$url" | sed -E 's|.*git@(.*?):|https://\1/|')
    fi
    url=''${url%.git} # chop off suffix

    if [[ -f $abspath ]]; then
      gitRoot=$(${git} rev-parse --show-toplevel)
      relpath=''${abspath#"$gitRoot"}

      branch=$(${git} rev-parse --abbrev-ref HEAD)
      url="$url/blob/$branch$relpath"
      if [ -n "$lineNum" ]; then
        url="$url#L$lineNum"
      fi
    fi

    popd 1>/dev/null
    xdg-open "$url" || echo "$url"
  ''
