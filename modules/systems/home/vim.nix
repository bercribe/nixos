{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.local.vim;
in {
  options.local.vim = with lib;
  with types; {
    languageServers = mkOption {
      type = attrsOf (nullOr package);
      description = "Language servers to use. Key is the name of the LSP in nvim-lspconfig, value is the package.";
      default = with pkgs; {
        clangd = null;
        lua_ls = lua-language-server;
        nixd = nixd;
        pyright = pyright;
        tinymist = tinymist;
      };
    };
    treesitterParsers = mkOption {
      type = listOf str;
      description = "Treesitter parsers to use";
      default = ["lua" "nix" "python" "typst"];
    };
  };

  config = {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      plugins = let
        toLua = str: "lua << EOF\n${str}\nEOF\n";
      in
        with pkgs.vimPlugins; [
          fzf-lua # quick opener w/ fzf
          nvim-lspconfig # language servers
          typst-preview-nvim # live preview for typst
          yazi-nvim # file picker
          {
            plugin = blink-cmp; # auto completion
            config = toLua ''
              require('blink.cmp').setup({
                -- C-y to accept
                -- C-space: Open menu or open docs if already open
                -- C-n/C-p or Up/Down: Select next/previous item
                -- C-e: Hide menu
                -- C-k: Toggle signature help (if signature.enabled = true)
                keymap = { preset = 'default' },

                appearance = {
                  nerd_font_variant = 'mono'
                },
                completion = { documentation = { auto_show = false } },
                sources = {
                  default = { 'lsp', 'path', 'snippets', 'buffer' },
                },
                fuzzy = { implementation = "prefer_rust_with_warning" }
              })
            '';
          }
          {
            plugin = oil-nvim; # file explorer
            config = toLua "require('oil').setup()";
          }
          {
            plugin = nvim-treesitter; # syntax highlighting
            config = toLua ''
              require('nvim-treesitter.configs').setup({
                highlight = {enable = true},
              })
            '';
          }
          (nvim-treesitter.withPlugins (p: map (t: p."${t}") cfg.treesitterParsers))
        ];
      extraLuaConfig = ''
        ${builtins.readFile ./vim.lua}

        -- lsp servers
        vim.lsp.enable({
          ${
          builtins.concatStringsSep ", "
          (lib.mapAttrsToList (name: _: "'${name}'") cfg.languageServers)
        }
        })
      '';
      extraPackages = let
        lsp = with lib; filter (s: s != null) (mapAttrsToList (_: pkg: pkg) cfg.languageServers);
        fmt = with pkgs; [alejandra];
      in
        lsp ++ fmt;
    };
  };
}
