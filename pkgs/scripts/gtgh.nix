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
      abspath=$(realpath $path)
      pushd $(dirname "$path")
    elif [[ -d $path ]]; then
      pushd $path
    else
      pushd .
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

    popd
    echo "$url"
    xdg-open "$url"
  ''
