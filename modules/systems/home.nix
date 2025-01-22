# `man home-configuration.nix` to view configurable options
{
  self,
  config,
  pkgs,
  lib,
  ...
}: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "mawz";
  home.homeDirectory = "/home/mawz";

  nixpkgs.config = import ./nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

  # for fzf bash integration
  programs.bash.enable = true;
  programs.fzf.enable = true;

  # generate key: `ssh-keygen -t ed25519 -C "mawz@hey.com"`
  # ssh config
  # use `ssh-copy-id` to add key to remote
  # `ssh-add` to forward credentials
  programs.ssh = let
    user = "mawz";
    forwardAgent = true;
  in {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      judgement = {
        inherit user forwardAgent;
        hostname = "judgement.mawz.dev";
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

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      telescope-nvim
      telescope-fzf-native-nvim
      neo-tree-nvim
      nvim-web-devicons
    ];
    extraConfig = ''
      " Fix tabs
      set tabstop=2 shiftwidth=2 smarttab
      " Use spaces instead of tabs
      set expandtab
      " Use system clipboard
      set clipboard=unnamedplus
      " Find files using Telescope command-line sugar.
      nnoremap <leader>ff <cmd>Telescope find_files<cr>
      nnoremap <leader>fg <cmd>Telescope live_grep<cr>
      nnoremap <leader>fb <cmd>Telescope buffers<cr>
      nnoremap <leader>fh <cmd>Telescope help_tags<cr>
      " Show file tree
      nnoremap <leader>tr :Neotree reveal right<cr>
      nnoremap <leader>tt :Neotree toggle right<cr>
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

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
