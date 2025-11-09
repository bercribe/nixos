{
  pkgs,
  lib,
  ...
}: let
  tmux = lib.getExe pkgs.tmux;
in
  pkgs.writeShellScriptBin "sf" ''
    # sf.sh - session finder
    # launches a fuzzy find picker and opens the selected directory in tmux
    # optionally takes an argument as the selected directory

    IFS=: read -ra dirs <<< $SF_DIRS

    if [[ $# -eq 1 ]]; then
      selected=$1
    else
      selected=$(${lib.getExe pkgs.fd} . "''${dirs[@]}" --type=dir --max-depth=1 $SF_FD_FLAGS 2>/dev/null |
        ${lib.getExe pkgs.fzf} --no-sort --delimiter / --with-nth -3..)
    fi

    [[ ! $selected ]] && exit 0

    path="$selected"
    session_name=$(basename "$path" | tr . _)

    if ! ${tmux} has-session -t "$session_name"; then
      ${tmux} new-session -ds "$session_name" -c "$path"
    fi

    if [[ -z $TMUX ]]; then
      ${tmux} a -t "$session_name"
    else
      ${tmux} switch-client -t "$session_name"
    fi
  ''
