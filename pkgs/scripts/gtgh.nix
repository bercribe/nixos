{
  pkgs,
  lib,
  ...
}: let
  git = lib.getExe pkgs.git;
in
  pkgs.writeShellScriptBin "gtgh" ''
    # gtgh.sh - goto github
    # usage:
    #   --upstream should usually be "origin"
    #   --path should be a file in the repo
    #   --line should be a line number


    # set up args
    # ignore errexit with `&& true`
    getopt --test > /dev/null && true
    if [[ $? -ne 4 ]]; then
        echo 'I’m sorry, `getopt --test` failed in this environment.'
        exit 1
    fi

    LONGOPTS=upstream:,path:,line:
    OPTIONS=u:p:l:

    # -temporarily store output to be able to check for errors
    # -activate quoting/enhanced mode (e.g. by writing out “--options”)
    # -pass arguments only via   -- "$@"   to separate them correctly
    # -if getopt fails, it complains itself to stdout
    PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@") || exit 2
    # read getopt’s output this way to handle the quoting right:
    eval set -- "$PARSED"

    # now enjoy the options in order and nicely split until we see --
    while true; do
        case "$1" in
            -u|--upstream)
                upstream="$2"
                shift 2
                ;;
            -p|--path)
                path="$2"
                shift 2
                ;;
            -l|--line)
                line="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Programming error"
                exit 1
                ;;
        esac
    done

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

      if [ -n "$upstream" ]; then
        upstream="$upstream/"
      fi
      branch=$(${git} rev-parse --abbrev-ref ''${upstream}HEAD)
      branch=''${branch#"$upstream"}

      url="$url/blob/$branch$relpath"
      if [ -n "$line" ]; then
        url="$url#L$line"
      fi
    fi

    popd 1>/dev/null
    xdg-open "$url" || echo "$url"
  ''
