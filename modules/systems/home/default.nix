# `man home-configuration.nix` to view configurable options
{
  pkgs,
  lib,
  local,
  ...
}: let
  utils = local.utils;
in {
  imports = [
    ./minimal.nix
    ./stylix.nix
    ../../../constants
    ../../../local-args
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "mawz";
  home.homeDirectory = "/home/mawz";

  home.shellAliases = {
    csc = "python ${pkgs.errata}/check_sync_conflicts.py";
    wake-hd = "wol 04:D9:F5:7B:DF:D8; wol 04:D9:F5:7B:DF:D9";
    cat = "bat";
    diff = "delta";
    ls = "eza";
  };
  programs.zsh.zsh-abbr.abbreviations = {
    nhs = "nh home switch ~/sources/nixos";
    nrs = "~/sources/nixos/rebuild-switch.sh";
  };

  nixpkgs.config = import ./nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

  # ssh config
  # use `ssh-copy-id` to add key to remote
  # `ssh-add` to forward credentials
  programs.ssh = let
    user = "mawz";
    forwardAgent = true;
    addKeysToAgent = "yes";
  in {
    enable = true;
    includes = ["~/.ssh/transient.conf"];
    enableDefaultConfig = false;
    matchBlocks = {
      echoes = {
        inherit user forwardAgent addKeysToAgent;
        hostname = "echoes.${local.secrets.personal-domain}";
        localForwards = [
          {
            bind.port = 8080;
            host.address = "127.0.0.1";
            host.port = 48815;
          }
        ];
      };
      judgement = {
        inherit user forwardAgent addKeysToAgent;
        hostname = utils.hostDomain "judgement";
      };
      lovers = {
        inherit forwardAgent addKeysToAgent;
        user = "root";
        hostname = utils.hostDomain "lovers";
      };
      mr-president = {
        inherit user forwardAgent addKeysToAgent;
        hostname = utils.hostDomain "mr-president";
        setEnv = {
          # check /usr/share/terminfo
          TERM = "xterm-color";
        };
      };
      moody-blues = {
        inherit user forwardAgent addKeysToAgent;
        hostname = utils.hostDomain "moody-blues";
      };
      super-fly = {
        inherit user forwardAgent addKeysToAgent;
        hostname = utils.hostDomain "super-fly";
      };
      super-fly-decrypt = {
        hostname = utils.hostDomain "super-fly";
        port = 2222;
        user = "root";
      };
    };
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "mawz";
      email = local.secrets.email;
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "mawz";
        email = local.secrets.email;
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "decorations";
      decorations = {
        file-decoration-style = "none";
        file-style = "bold yellow ul";
        hunk-header-decoration-style = "none";
      };
    };
  };

  programs.difftastic = {
    enable = true;
    git.diffToolMode = true;
  };

  programs.tmux.terminal = "foot";

  local.packages.includeScripts = true;
  local.yazi.useMux = true;
  local.yazi.keybinds = {
    drag-and-drop = {
      bind = "<C-n>";
      command = ''shell -- ${lib.getExe pkgs.dragon-drop} -x -i -T -a "$@"'';
    };
    copy-to-clipboard = {
      bind = "y";
      command = [''shell -- for path in "$@"; do echo "file://$path"; done | ${pkgs.wl-clipboard}/bin/wl-copy -t text/uri-list'' "yank"];
    };
  };
  local.programs.sf.directories = ["$HOME" "$HOME/personal-cloud" "$HOME/sources" "$HOME/sources/scripts"];

  # docs:
  #   - https://github.com/gokcehan/lf/blob/master/doc.md
  #   - https://github.com/gokcehan/lf/wiki/Tips
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
          ${pkgs.dragon-drop}/bin/xdragon -a -x "''${files[@]}"
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

  # Theme settings
  # needed for stylix theming
  programs.btop.enable = true;
  programs.foot.enable = true;
  programs.ghostty.enable = true;
}
