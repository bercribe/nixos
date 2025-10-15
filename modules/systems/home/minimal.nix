{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.local;
in {
  imports = [./vim.nix];

  options.local.yazi = with lib;
  with types; {
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

  config = {
    home.shellAliases = {
      reload-env = "eval $(tmux show-env -s)";
      vim = "nvim";
    };

    programs.bash = {
      enable = true;
      initExtra = ''
        # fixes issue where home.sessionVariables have no effect
        # https://github.com/nix-community/home-manager/issues/1011
        source "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh";

        # Aliases with bash completion
        . ${lib.getExe pkgs.complete-alias}
        alias sctl='systemctl'
        complete -F _complete_alias sctl
        alias jctl='journalctl'
        complete -F _complete_alias jctl
        alias jfu='journalctl -f -u'
        complete -F _complete_alias jfu
      '';
    };

    # for fzf bash integration
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
      terminal = "foot";
      extraConfig = ''
        # fix warnings caused by UWSM
        set -g default-command "''${SHELL}"

        bind O switch-client -l
        bind g display-popup -E "sf"
      '';
    };

    programs.yazi = {
      enable = true;

      plugins = with pkgs.yaziPlugins; {
        piper = piper; # pipe any shell command as a previewer
      };
      settings = {
        manager.linemode = "size";
        opener.open = [
          {
            run = ''$OPENER "$@"'';
            desc = "Open";
            orphan = true;
          }
        ];
        plugin = {
          prepend_previewers = [
            # sometimes useful - previews date photo was taken
            # {
            #   mime = "image/*";
            #   run = ''piper -- ${lib.getExe pkgs.exiftool} -S -DateTimeOriginal -MediaCreateDate -FileModifyDate "$1"'';
            # }
          ];
        };
      };
      keymap = {
        manager.prepend_keymap = let
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
          [
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
      '';
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
