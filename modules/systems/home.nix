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

  # for fzf bash integration
  programs.bash.enable = true;
  programs.fzf.enable = true;

  # generate key: `ssh-keygen -t ed25519 -C "mawz@hey.com"`
  # ssh config
  # use `ssh-copy-id` to add key to remote
  # `ssh-add` to forward credentials
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      mawz-nuc = {
        hostname = "192.168.0.54";
        user = "mawz";
      };
      mawz-nas = {
        hostname = "192.168.0.43";
        user = "mawz";
        setEnv = {
          # check /usr/share/terminfo
          TERM = "xterm-color";
        };
      };
      mawz-nvr = {
        hostname = "192.168.0.32";
        user = "mawz";
      };
      mawz-vault = {
        hostname = "192.168.0.51";
        user = "mawz";
      };
      mawz-vault-decrypt = {
        hostname = "192.168.0.51";
        port = 2222;
        user = "root";
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "mawz";
    userEmail = "mawz@hey.com";
  };

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      telescope-nvim
      telescope-fzf-native-nvim
    ];
    extraConfig = ''
      "Use system clipboard
      set clipboard=unnamedplus
      " Find files using Telescope command-line sugar.
      nnoremap <leader>ff <cmd>Telescope find_files<cr>
      nnoremap <leader>fg <cmd>Telescope live_grep<cr>
      nnoremap <leader>fb <cmd>Telescope buffers<cr>
      nnoremap <leader>fh <cmd>Telescope help_tags<cr>
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
      gn = "cd /mnt/mawz-nas";
      gv = "cd /mnt/mawz-vault";
      gd = "cd /mnt/distant-disk";
    };
    previewer.source = pkgs.writeShellScript "pv.sh" ''
      #!/bin/sh

      shopt -s nocasematch
      case "$1" in
          *.avi | *.bmp | *.gif | *.jpg | *.jpeg | *.mov | *.mpg | *.mp4 | *.pcx | *.png | *.psd | *.thm | *.wav)
              ${pkgs.exiftool}/bin/exiftool -S -DateTimeOriginal -MediaCreateDate -FileModifyDate "$1";
              echo "--------------------------------"; ${pkgs.exiftool}/bin/exiftool "$1";;
          *.tar*) tar tf "$1";;
          *.zip) unzip -l "$1";;
          *.rar) unrar l "$1";;
          *.7z) 7z l "$1";;
          *.pdf) pdftotext "$1" -;;
          *) highlight -O ansi "$1" || cat "$1";;
      esac
    '';
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
