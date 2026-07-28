{
  pkgs,
  lib,
  ...
}: {
  home.shellAliases.reload-env = "eval $(tmux show-env -s)";

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    baseIndex = 1;
    mouse = true;
    escapeTime = 0;
    customPaneNavigationAndResize = true;
    focusEvents = true;
    sensibleOnTop = true;
    terminal = lib.mkDefault "tmux-256color";
    extraConfig = let
      devLayout = pkgs.writeShellScriptBin "dev-layout" ''
        tmux split-window -h \; send-keys '$EDITOR' Enter \; select-pane -L
      '';
      devLayoutFull = pkgs.writeShellScriptBin "dev-layout-full" ''
        tmux split-window -h \; send-keys '$EDITOR' Enter \; select-pane -L \; split-window -v \; send-keys 'agent' Enter \; select-pane -U
      '';
      editScrollback = pkgs.writeShellScriptBin "edit-scrollback" ''
        tmpfile=$(mktemp /tmp/tmux-pane-XXXXXX)
        tmux capture-pane -p -S - > $tmpfile
        tmux new-window "$EDITOR $tmpfile '+set nowrap' '+normal GH2k'; rm $tmpfile"
      '';
      pane_path = ''#{pane_current_path}'';
    in ''
      # fix warnings caused by UWSM
      set -g default-command "''${SHELL}"

      # enable clipboard in tmux over ssh
      set -s set-clipboard on
      set -as terminal-features ',screen-256color:clipboard'

      # enable true color
      set -ga terminal-overrides ",*-256color:Tc"

      bind u switch-client -l
      bind g display-popup -E "st"
      bind e run-shell "${lib.getExe editScrollback}"
      bind y run-shell "tmux set-buffer -w '${pane_path}'"
      bind a run-shell 'tmux display-popup -E "fa \"${pane_path}\""'
      bind U select-layout -o
      bind v run-shell "${lib.getExe devLayout}"
      bind V run-shell "${lib.getExe devLayoutFull}"

      # make these repeatable
      bind -r % split-window -h
      bind -r '"' split-window -v

      # for switching split direction
      bind -r S-Up move-pane -h -t '.{up-of}'
      bind -r S-Down move-pane -h -t '.{down-of}'
      bind -r S-Left move-pane -t '.{left-of}'
      bind -r S-Right move-pane -t '.{right-of}'

      # layout quick loads
      bind M-6 run-shell "tsl 6"
      bind M-7 run-shell "tsl 7"
      bind M-8 run-shell "tsl 8"
      bind M-9 run-shell "tsl 9"
      bind M-0 run-shell "tsl 0"
    '';
  };
}
