# `man home-configuration.nix` to view configurable options
{
  config,
  pkgs,
  ...
}: {
  imports = [../../modules/hyprland/config.nix];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "mawz";
  home.homeDirectory = "/home/mawz";

  # Git config
  programs.git = {
    enable = true;
    userName = "mawz";
    userEmail = "mawz@hey.com";
  };

  # ssh config
  # use `ssh-copy-id` to add key to remote
  programs.ssh = {
    enable = true;
    matchBlocks = {
      mawz-nuc = {
        port = 22;
        hostname = "192.168.0.54";
        user = "mawz";
      };
      mawz-nas = {
        port = 22;
        hostname = "192.168.0.43";
        user = "mawz";
        setEnv = {
          # check /usr/share/terminfo
          TERM = "xterm-color";
        };
      };
      mawz-nvr = {
        port = 22;
        hostname = "192.168.0.32";
        user = "mawz";
      };
    };
  };

  # inspiration:
  #   - https://github.com/gokcehan/lf/blob/master/doc.md
  #   - https://github.com/gokcehan/lf/wiki/Tips
  #   - https://github.com/vimjoyer/lf-nix-video
  programs.lf = {
    enable = true;
    commands = {
      copy-path = ''
        ''${{
        ${pkgs.wl-clipboard}/bin/wl-copy $f
        }}
      '';
    };
    keybindings = {
      "<c-c>" = "copy-path";
      a = "push %mkdir<space>";
    };
    previewer.source = pkgs.writeShellScript "pv.sh" ''
      #!/bin/sh

      shopt -s nocasematch
      case "$1" in
          *.avi | *.gif | *.jpg | *.jpeg | *.mov | *.mpg | *.mp4 | *.pcx | *.png | *.psd | *.thm | *.wav)
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
