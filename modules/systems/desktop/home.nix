# `man home-configuration.nix` to view configurable options
{
  config,
  pkgs,
  lib,
  stylix,
  ...
}: {
  imports = [
    ../../home
    ../../hyprland/config.nix
  ];

  programs.bash.enable = true;
  programs.dircolors = {
    enable = true;
    settings = {
      OTHER_WRITABLE = "30;46";
    };
  };

  programs.firefox = {
    enable = true;
    profiles.mawz = {
      isDefault = true;
      search = {
        default = "Kagi";
        force = true;
        engines = {
          "Kagi" = {
            urls = [
              {template = "https://kagi.com/search?q={searchTerms}";}
              {
                template = "https://kagi.com/api/autosuggest?q={searchTerms}";
                type = "application/x-suggestions+json";
              }
            ];
            iconUpdateUrl = "https://assets.kagi.com/v2/favicon-32x32.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = ["@kagi"];
          };
          "Nix Packages" = {
            urls = [{template = "https://search.nixos.org/packages?query={searchTerms}";}];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@np"];
          };
          "Nix Options" = {
            urls = [{template = "https://search.nixos.org/options?query={searchTerms}";}];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@no"];
          };
          "Home Manager" = {
            urls = [{template = "https://home-manager-options.extranix.com/?query={searchTerms}";}];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@hm"];
          };
        };
      };
    };
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      ms-vscode-remote.remote-ssh
    ];
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
      copy-name = ''
        ''${{
        basename "$f" | ${pkgs.wl-clipboard}/bin/wl-copy
        }}
      '';
      copy-dir = ''
        ''${{
        dirname "$f" | ${pkgs.wl-clipboard}/bin/wl-copy
        }}
      '';
      dragon-out = ''
        ''${{
          ${pkgs.xdragon}/bin/xdragon -a -x "$fx"
        }}
      '';
    };
    keybindings = {
      y = null;
      yy = "copy";
      yp = "copy-path";
      yn = "copy-name";
      yd = "copy-dir";
      a = "push %mkdir<space>";
      o = "dragon-out";
      gn = "cd /mnt/mawz-nas";
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

  # needed for stylix theming
  programs.alacritty.enable = true;
  programs.btop.enable = true;
  programs.fzf.enable = true;
  programs.tmux.enable = true;
  programs.vim.enable = true;
  stylix.targets.firefox.profileNames = ["mawz"];
  gtk.enable = true;
}
