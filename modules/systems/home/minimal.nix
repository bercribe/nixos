{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.local;
in {
  imports = [
    ./tmux.nix
    ./vim.nix
    ./yazi.nix
    ./zsh.nix
    ../../../constants
  ];

  options.local = with lib;
  with types; {
    packages.includeScripts = mkEnableOption "scripts";
  };

  config = {
    home.packages = let
      packages = config.local.constants.packages;
    in
      packages.core ++ (lib.optionals cfg.packages.includeScripts packages.scripts);

    home.shellAliases = {
      cd = "z";
    };

    # shell integrations
    programs.fzf.enable = true;
    programs.zoxide.enable = true;
    programs.atuin = {
      enable = true;
      flags = [
        "--disable-up-arrow"
      ];
      settings = {
        inline_height = 16;
      };
      # improves performance on zfs systems
      daemon.enable = true;
    };
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
