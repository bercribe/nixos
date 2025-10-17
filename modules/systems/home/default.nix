# `man home-configuration.nix` to view configurable options
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./minimal.nix
    ./stylix.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "mawz";
  home.homeDirectory = "/home/mawz";

  home.shellAliases = {
    cat = "bat";
    csc = "python ${pkgs.errata}/check_sync_conflicts.py";
    diff = "difft";
    ls = "eza";
    nhs = "nh home switch ~/sources/nixos";
    nrs = "~/sources/nixos/rebuild-switch.sh";
    wake-hd = "wol 04:D9:F5:7B:DF:D8; wol 04:D9:F5:7B:DF:D9";
  };

  nixpkgs.config = import ./nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

  # ssh config
  # use `ssh-copy-id` to add key to remote
  # `ssh-add` to forward credentials
  programs.ssh = let
    user = "mawz";
    forwardAgent = true;
  in {
    enable = true;
    addKeysToAgent = "yes";
    includes = ["~/.ssh/transient.conf"];
    matchBlocks = {
      judgement = {
        inherit user forwardAgent;
        hostname = "judgement.mawz.dev";
      };
      lovers = {
        inherit forwardAgent;
        user = "root";
        hostname = "lovers.mawz.dev";
      };
      mr-president = {
        inherit user forwardAgent;
        hostname = "mr-president.mawz.dev";
        setEnv = {
          # check /usr/share/terminfo
          TERM = "xterm-color";
        };
      };
      moody-blues = {
        inherit user forwardAgent;
        hostname = "moody-blues.mawz.dev";
      };
      super-fly = {
        inherit user forwardAgent;
        hostname = "super-fly.mawz.dev";
      };
      super-fly-decrypt = {
        hostname = "super-fly.mawz.dev";
        port = 2222;
        user = "root";
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "mawz";
    userEmail = "mawz@hey.com";
    difftastic.enable = true;
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "mawz";
        email = "mawz@hey.com";
      };
    };
  };

  programs.tmux.terminal = "foot";

  local.yazi.keybinds = {
    drag-and-drop = {
      bind = "<C-n>";
      command = ''shell -- ${lib.getExe pkgs.xdragon} -x -i -T -a "$@"'';
    };
    copy-to-clipboard = {
      bind = "y";
      command = [''shell -- for path in "$@"; do echo "file://$path"; done | ${pkgs.wl-clipboard}/bin/wl-copy -t text/uri-list'' "yank"];
    };
  };

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

  # Theme settings
  # needed for stylix theming
  programs.btop.enable = true;
  programs.foot.enable = true;
  programs.ghostty.enable = true;
}
