{
  pkgs,
  lib,
  ...
}: {
  programs.neovim = let
    languageServers = with pkgs; {
      clangd = libclang;
      lua_ls = lua-language-server;
      nixd = nixd;
      pyright = pyright;
    };
    treesitterSyntaxes =
      pkgs.vimPlugins.nvim-treesitter.withPlugins
      (p: with p; [lua nix python]);
  in {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig # language servers
      telescope-nvim # quick opener w/ fzf
      {
        plugin = oil-nvim; # file explorer
        config = ''
          packadd! oil.nvim
          lua <<EOF
            require'oil'.setup()
          EOF
        '';
      }
      {
        plugin = nvim-treesitter; # syntax highlighting
        config = ''
          packadd! nvim-treesitter
          lua <<EOF
            require'nvim-treesitter.configs'.setup {
              highlight = {enable = true},
            }
          EOF
        '';
      }
      treesitterSyntaxes
    ];
    extraLuaConfig = let
      main = builtins.readFile ./vim.lua;
      lsp = ''
        vim.lsp.enable({
          ${
          builtins.concatStringsSep ", "
          (lib.mapAttrsToList (name: _: "'${name}'") languageServers)
        }
        })
      '';
    in
      main + lsp;
    extraPackages = let
      lsp = lib.mapAttrsToList (_: pkg: pkg) languageServers;
      fmt = with pkgs; [alejandra];
    in
      lsp ++ fmt;
  };
}
