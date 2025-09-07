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
      tinymist = tinymist;
    };
    treesitterSyntaxes =
      pkgs.vimPlugins.nvim-treesitter.withPlugins
      (p: with p; [lua nix python typst]);
  in {
    enable = true;
    defaultEditor = true;
    plugins = let
      toLua = str: "lua << EOF\n${str}\nEOF\n";
    in
      with pkgs.vimPlugins; [
        nvim-lspconfig # language servers
        telescope-nvim # quick opener w/ fzf
        typst-preview-nvim # live preview for typst
        {
          plugin = oil-nvim; # file explorer
          config = ''
            packadd! oil.nvim
            ${toLua "require'oil'.setup()"}
          '';
        }
        {
          plugin = nvim-treesitter; # syntax highlighting
          config = ''
            packadd! nvim-treesitter
            ${toLua ''
              require'nvim-treesitter.configs'.setup {
                highlight = {enable = true},
              }
            ''}
          '';
        }
        treesitterSyntaxes
      ];
    extraLuaConfig = ''
      ${builtins.readFile ./vim.lua}

      -- lsp servers
      vim.lsp.enable({
        ${
        builtins.concatStringsSep ", "
        (lib.mapAttrsToList (name: _: "'${name}'") languageServers)
      }
      })
    '';
    extraPackages = let
      lsp = lib.mapAttrsToList (_: pkg: pkg) languageServers;
      fmt = with pkgs; [alejandra];
    in
      lsp ++ fmt;
  };
}
