{
  pkgs,
  lib,
  ...
}: {
  home.sessionVariables.SHELL = lib.getExe pkgs.zsh;
  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";

    syntaxHighlighting.enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      strategy = ["history" "completion"];
    };

    history = {
      extended = true;
      expireDuplicatesFirst = true;
      findNoDups = true;
      ignoreAllDups = true;
    };
    historySubstringSearch.enable = true;

    zsh-abbr = {
      enable = true;
      abbreviations = {
        "git m" = ''git commit -m "%"'';
        jctl = "journalctl";
        jfu = "journalctl -f -u";
        nsu = "nix shell github:NixOS/nixpkgs/nixos-unstable#%";
        sctl = "systemctl";
        vim = "nvim";
      };
      globalAbbreviations = {
        "S:" = ''| sed "s/:/\\n/g"'';
      };
    };

    # prompt
    initContent = let
      prompt = lib.mkOrder 500 ''
        # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
        # Initialization code that may require console input (password prompts, [y/n]
        # confirmations, etc.) must go above this block; everything else may go below.
        if [[ -r "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      '';
      config = lib.mkOrder 1000 ''
        # enables cursor manipulation for abbreviations using %
        ABBR_SET_EXPANSION_CURSOR=1

        # typo correction
        setopt correct

        # completion styling
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # case insensitive completion
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}" # directory colors

        # enable zmv
        autoload -Uz zmv

        # autocomplete
        bindkey '^ ' autosuggest-accept

        # edit current line
        autoload -z edit-command-line
        zle -N edit-command-line
        bindkey "^Xe" edit-command-line

        # copy current line
        function copy-buffer-to-clipboard() {
          echo -n "$BUFFER" | copy
          zle -M "Copied to clipboard"
        }
        zle -N copy-buffer-to-clipboard
        bindkey '^Xc' copy-buffer-to-clipboard

        # fzf command arg menu
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        zstyle ':completion:*' menu no # disable default
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath' # display directory contents on cd
        zstyle ':fzf-tab:*' fzf-bindings 'ctrl-j:toggle+down,ctrl-k:toggle+up'

        # suffix aliases
        alias -s log=bat
        alias -s txt=bat
        alias -s md=bat
        alias -s json=jless
        alias -s nix='$EDITOR'
        alias -s py='$EDITOR'
        alias -s rs='$EDITOR'
        alias -s html=opn

        # fixes nix-shell and nix develop to use zsh
        ${lib.getExe pkgs.any-nix-shell} zsh --info-right | source /dev/stdin
      '';
    in
      lib.mkMerge [prompt config];

    # zprof.enable = true;
  };
  home.file.p10k = {
    source = ./p10k.zsh;
    target = ".p10k.zsh";
  };
}
