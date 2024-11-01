# A rebuild script that commits on a successful build
# based on: https://gist.github.com/0atman/1a5133b842f929ba4c1e195ee67599d5
set -e

# set up args
# ignore errexit with `&& true`
getopt --test > /dev/null && true
if [[ $? -ne 4 ]]; then
    echo 'I’m sorry, `getopt --test` failed in this environment.'
    exit 1
fi

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  headless=true
# many other tests omitted
else
    case $(ps -o comm= -p "$PPID") in
        sshd|*/sshd) headless=true;;
    esac
fi


LONGOPTS=test,force,show-trace,update
OPTIONS=tfsu

# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
# -if getopt fails, it complains itself to stdout
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@") || exit 2
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

disableCommit=false forceRun=false showTrace=false update=false
# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -t|--test)
            disableCommit=true
            shift
            ;;
        -f|--force)
            forceRun=true
            shift
            ;;
        -s|--show-trace)
            showTrace=true
            shift
            ;;
        -u|--update)
            update=true
            shift
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

# cd to your config dir
pushd $(dirname "$0")

# Early return if no changes were detected (thanks @singiamtel!)
if [ "$forceRun" != true ] && git diff HEAD --quiet '*.nix'; then
    echo "No changes detected, exiting."
    popd
    exit 0
fi

# Autoformat your nix files
alejandra . &>/dev/null \
  || ( alejandra . ; echo "formatting failed!" && exit 1)

# Shows your changes
git add .
git diff HEAD -U0 '*.nix'

echo "NixOS rebuilding $HOSTNAME..."

# Rebuild
rebuildCmd=(sudo nixos-rebuild switch --flake .#${HOSTNAME})
if [ "$showTrace" == true ]; then
    rebuildCmd+=(--show-trace --option eval-cache false)
fi
"${rebuildCmd[@]}" || exit 1

# Get current generation metadata
current=$(nixos-rebuild list-generations | grep current)

# Commit all changes witih the generation metadata
if [ "$disableCommit" != true ]; then
    git commit -am "${HOSTNAME}: $current" || true
fi

# Back to where you were
popd

# Fix command-not-found functionality
if [ "$update" == true ]; then
    sudo -i nix-channel --update
fi

# Notify all OK!
echo "NixOS Rebuilt OK!"
if [ "$headless" != true ]; then
    notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available
fi
