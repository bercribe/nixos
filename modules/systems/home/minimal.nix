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
            type = listOf str;
            description = "Keyboard inputs";
          };
          command = mkOption {
            type = str;
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

    # inspiration:
    #   - https://github.com/gokcehan/lf/blob/master/doc.md
    #   - https://github.com/gokcehan/lf/wiki/Tips
    #   - https://github.com/vimjoyer/lf-nix-video
    programs.lf = {
      enable = true;
      commands = let
        copy-cmd = "${pkgs.wl-clipboard}/bin/wl-copy";
      in {
        copy-path = ''
          ''${{
          ${copy-cmd} $f
          }}
        '';
        copy-name = ''
          ''${{
          basename "$f" | ${copy-cmd}
          }}
        '';
        copy-dir = ''
          ''${{
          dirname "$f" | ${copy-cmd}
          }}
        '';
        copy-files = ''
          ''${{
            echo "$fx" | awk '{ print "file://" $0 }' | ${copy-cmd} -t text/uri-list
          }}
        '';
        dragon-out = ''
          ''${{
            readarray -t files <<<"$fx"
            ${pkgs.xdragon}/bin/xdragon -a -x "''${files[@]}"
          }}
        '';
      };
      keybindings = {
        y = null;
        yy = "copy";
        yp = "copy-path";
        yn = "copy-name";
        yd = "copy-dir";
        yf = "copy-files";
        yo = "dragon-out";
        a = "push %mkdir<space>";
        gd = "cd /mnt/gdrive";
        gf = "cd /mnt/super-fly";
        gm = "cd /mnt/mr-president";
      };
      previewer = {
        keybinding = "i";
        source = pkgs.writeShellScript "pv.sh" ''
          #!/bin/sh

          mimeType=$(xdg-mime query filetype "$1")
          echo "Mime type: $mimeType"

          shopt -s nocasematch
          case "$mimeType" in
              video/* | audio/* | image/*)
                  ${pkgs.exiftool}/bin/exiftool -S -DateTimeOriginal -MediaCreateDate -FileModifyDate "$1";
                  echo "--------------------------------";; #${pkgs.exiftool}/bin/exiftool "$1";;
          esac
          case "$1" in
              *.tar*) tar tf "$1";;
              *.zip) unzip -l "$1";;
              *.rar) unrar l "$1";;
              *.7z) 7z l "$1";;
              *.pdf) pdftotext "$1" -;;
              # *) highlight -O ansi "$1" || cat "$1";;
          esac

          less "$1"
        '';
      };
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
            # drag and drop
            {
              on = "<C-n>";
              run = ''shell -- ${lib.getExe pkgs.xdragon} -x -i -T -a "$@"'';
            }
            # copy to system clipboard
            {
              on = "y";
              run = [''shell -- for path in "$@"; do echo "file://$path"; done | ${pkgs.wl-clipboard}/bin/wl-copy -t text/uri-list'' "yank"];
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
