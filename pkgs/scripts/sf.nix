{
  config,
  pkgs,
  lib,
  ...
}: {
  options.local.sf = with lib;
  with types; {
    directories = mkOption {
      type = listOf str;
      default = ["~"];
      example = ["~" "~/sources"];
      description = "Directories to select from";
    };
  };

  config = {
    environment.systemPackages = let
      sf = pkgs.writeShellScriptBin "sf" ''
        # sf.sh - session finder
        # launches a fuzzy find picker and opens the selected directory in tmux
        # optionally takes an argument as the selected directory

        dirs=(${lib.concatStringsSep " " config.local.sf.directories})

        if [[ $# -eq 1 ]]; then
          selected=$1
        else
          selected=$(${lib.getExe pkgs.fd} . "''${dirs[@]}" --type=dir --max-depth=1 |
            ${lib.getExe pkgs.fzf} --delimiter / --with-nth -3..)
        fi

        [[ ! $selected ]] && exit 0

        path="$selected"
        session_name=$(basename "$path" | tr . _)

        if ! tmux has-session -t "$session_name"; then
          tmux new-session -ds "$session_name" -c "$path"
        fi

        if [[ -z $TMUX ]]; then
          tmux a -t "$session_name"
        else
          tmux switch-client -t "$session_name"
        fi
      '';
    in [
      sf
      pkgs.tmux
    ];
  };
}
