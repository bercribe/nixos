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
      terminal = lib.mkDefault "screen-256color";
      extraConfig = ''
        # fix warnings caused by UWSM
        set -g default-command "''${SHELL}"

        # enable clipboard in tmux over ssh
        set -as terminal-features ',screen-256color:clipboard'

        bind O switch-client -l
        bind g display-popup -E "sf"
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
                  '${lib.getExe pkgs.exiftool} -S -DateTimeOriginal -MediaCreateDate -FileModifyDate "$1"',
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
