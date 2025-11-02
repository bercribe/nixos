{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.local;
in {
  imports = [
    ./vim.nix
    ../../../pkgs/scripts/sf/homeModule.nix
  ];

  options.local = with lib;
  with types; {
    packages.includeScripts = mkEnableOption "scripts";

    yazi = {
      useMux = mkEnableOption "mux";
      keybinds = mkOption {
        type = attrsOf (submodule {
          options = {
            bind = mkOption {
              type = either str (listOf str);
              description = "Keyboard inputs";
            };
            command = mkOption {
              type = either str (listOf str);
              description = "Command to run";
            };
          };
        });
        default = {};
        example = {
          goto-zsolid = {
            bind = ["g" "z" "s"];
            command = "cd /zsolid";
          };
        };
        description = "Keybinds to set in yazi";
      };
    };
  };

  config = {
    home.packages = let
      packages = import ../packages.nix pkgs;
    in
      packages.core ++ (lib.optionals cfg.packages.includeScripts packages.scripts);

    home.shellAliases = {
      reload-env = "eval $(tmux show-env -s)";
    };

    # shell
    home.sessionVariables.SHELL = lib.getExe pkgs.zsh;
    programs.bash = {
      enable = true;
      initExtra = "exec $SHELL";
    };
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
          vim = "nvim";
          sctl = "systemctl";
          jctl = "journalctl";
          jfu = "journalctl -f -u";
        };
        globalAbbreviations = {
          "s:" = ''| sed -s "s/:/\\n/g"'';
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
          # typo correction
          setopt correct

          # completion styling
          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # case insensitive completion
          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}" # directory colors

          # edit current line
          autoload -z edit-command-line
          zle -N edit-command-line
          bindkey "^X^E" edit-command-line

          # fzf command arg menu
          source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
          zstyle ':completion:*' menu no # disable default
          zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath' # display directory contents on cd
        '';
      in
        lib.mkMerge [prompt config];

      # zprof.enable = true;
    };
    home.file.p10k = {
      source = ./p10k.zsh;
      target = ".p10k.zsh";
    };

    # for fzf shell integration
    programs.fzf.enable = true;

    programs.tmux = {
      enable = true;
      keyMode = "vi";
      shortcut = "space";
      baseIndex = 1;
      mouse = true;
      escapeTime = 0;
      customPaneNavigationAndResize = true;
      focusEvents = true;
      sensibleOnTop = true;
      terminal = lib.mkDefault "tmux-256color";
      extraConfig = let
        editScrollback = pkgs.writeShellScriptBin "edit-scrollback" ''
          tmpfile=$(mktemp /tmp/tmux-pane-XXXXXX)
          tmux capture-pane -p -S - > $tmpfile
          tmux new-window "$EDITOR $tmpfile '+normal GH2k'"
        '';
      in ''
        # fix warnings caused by UWSM
        set -g default-command "''${SHELL}"

        # enable clipboard in tmux over ssh
        set -as terminal-features ',screen-256color:clipboard'

        bind u switch-client -l
        bind g display-popup -E "sf"
        bind e run-shell "${lib.getExe editScrollback}"
      '';
    };

    programs.yazi = {
      enable = true;

      plugins = with pkgs.yaziPlugins;
        {
          piper = piper; # pipe any shell command as a previewer
        }
        // lib.optionalAttrs cfg.yazi.useMux {
          mux = mux;
        };
      settings = {
        mgr.linemode = "size";
        opener.open = [
          {
            run = ''$OPENER "$@"'';
            desc = "Open";
            orphan = true;
          }
        ];
        plugin = {
          prepend_previewers = lib.optionals cfg.yazi.useMux [
            # prepend these to keep default behavior
            {
              mime = "image/{avif,hei?,jxl}";
              run = "magick";
            }
            {
              mime = "image/svg+xml";
              run = "svg";
            }
            {
              mime = "image/*";
              run = "mux image exiftool";
            }
          ];
        };
      };
      keymap = {
        mgr.prepend_keymap = let
          localKeybinds = with lib;
            mapAttrsToList (desc: {
              bind,
              command,
            }: {
              inherit desc;
              on = bind;
              run = command;
            })
            cfg.yazi.keybinds;
        in
          lib.optionals cfg.yazi.useMux [
            # cycle previewer
            {
              on = "<C-p>";
              run = "plugin mux next";
              desc = "Cycle through mux previewers";
            }
          ]
          ++ [
            # drop into shell
            {
              on = "!";
              run = ''shell "$SHELL" --block'';
              desc = "Open shell here";
            }
            # shortcuts
            {
              on = ["g" "/"];
              run = "cd /";
            }
            {
              on = ["g" "m" "g"];
              run = "cd /mnt/gdrive";
            }
            {
              on = ["g" "m" "s"];
              run = "cd /mnt/super-fly";
            }
            {
              on = ["g" "m" "m"];
              run = "cd /mnt/mr-president";
            }
            {
              on = ["g" "s" "c"];
              run = "cd ~/personal-cloud";
            }
            {
              on = ["g" "s" "p"];
              run = "cd ~/projects";
            }
          ]
          ++ localKeybinds;
      };
      initLua = ''
        require("session"):setup {
         sync_yanked = true,
        }

        ${lib.optionalString cfg.yazi.useMux ''
          -- plugins
          require("mux"):setup({
            remember_per_file_extension = true,
            aliases = {
              exiftool = {
                previewer = "piper",
                args = {
                  '${lib.getExe pkgs.exiftool} -S -DateTimeOriginal -MediaCreateDate -FileModifyDate "$1" | fmt -t -w $w',
                },
              },
            },
          })
        ''}
      '';
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
