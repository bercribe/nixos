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

LONGOPTS=test,force
OPTIONS=tf

# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
# -if getopt fails, it complains itself to stdout
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@") || exit 2
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

disableCommit=false forceRun=false
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

echo "NixOS Rebuilding..."

# Rebuild, output simplified errors, log trackebacks
sudo nixos-rebuild switch --flake .#${HOSTNAME} || exit 1

# Get current generation metadata
current=$(nixos-rebuild list-generations | grep current)

# Commit all changes witih the generation metadata
if [ "$disableCommit" != true ]; then
    git commit -am "${HOSTNAME}: $current"
fi

# Back to where you were
popd

# Notify all OK!
notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available

