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
      default = {};
    };
    treesitterParsers = mkOption {
      type = listOf str;
      description = "Treesitter parsers to use";
      default = [];
    };
    filetypes = mkOption {
      type = attrsOf (submodule {
        options = {
          tabsize = mkOption {
            type = int;
            description = "Sets tabstop and shiftwidth options";
            default = 4;
          };
          expandtab = mkOption {
            type = bool;
            description = "Sets expandtab option";
            default = true;
          };
          commentPattern = mkOption {
            type = str;
            description = "Populates comment bind";
            default = "";
          };
        };
      });
      description = "FileType autocmds. Keyed on pattern to use, usually the file extension. Check using :set filetype";
      default = {};
    };
  };

  config = {
    local.vim = {
      languageServers = with pkgs; {
        clangd = clang-tools;
        lua_ls = lua-language-server;
        nixd = nixd;
        pyright = pyright;
        tinymist = tinymist;
      };
      treesitterParsers = ["lua" "nix" "python" "typst"];
      filetypes = {
        "*" = {};
        lua.commentPattern = "--";
        nix = {
          tabsize = 2;
          commentPattern = "#";
        };
        python.commentPattern = "#";
      };
    };

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
      extraLuaConfig = let
        lspServers = with lib; concatStringsSep ", " (mapAttrsToList (name: _: "'${name}'") cfg.languageServers);

        filetypeAutocmds = with lib;
          concatStrings (mapAttrsToList (pattern: {
              tabsize,
              expandtab,
              ...
            }: ''
              vim.api.nvim_create_autocmd('FileType', {
                pattern = {'${pattern}'},
                callback = function()
                  vim.opt.tabstop = ${toString tabsize}
                  vim.opt.shiftwidth = ${toString tabsize}
                  vim.opt.expandtab = ${
                if expandtab
                then "true"
                else "false"
              }
                end,
              })
            '')
            cfg.filetypes);

        commentCommands = with lib; ''
          local comment_patterns = {
          ${
            concatStringsSep "\n" ((mapAttrsToList (pattern: {commentPattern, ...}: ''${pattern} = "${commentPattern} <CR>",'')) (filterAttrs (_: {commentPattern, ...}: ((stringLength commentPattern) > 0)) cfg.filetypes))
          }
          }

          vim.keymap.set({"n", "v"}, "<leader>c", function()
            local comment_pattern = comment_patterns[vim.bo.filetype] or ""
            local keys = vim.api.nvim_replace_termcodes(":norm 0i" .. comment_pattern, true, false, true)
            vim.api.nvim_feedkeys(keys, "n", false)
          end)
          vim.keymap.set({"n", "v"}, "<leader>C", function()
            local comment_pattern = comment_patterns[vim.bo.filetype] or ""
            local keys = vim.api.nvim_replace_termcodes(":norm I" .. comment_pattern, true, false, true)
            vim.api.nvim_feedkeys(keys, "n", false)
          end)
        '';
      in ''
        ${builtins.readFile ./vim.lua}

        -- comment commands
        ${commentCommands}

        -- lsp servers
        vim.lsp.enable({
          ${lspServers}
        })

        -- filetype autocmds
        ${filetypeAutocmds}
      '';
      extraPackages = let
        lsp = with lib; filter (s: s != null) (mapAttrsToList (_: pkg: pkg) cfg.languageServers);
        fmt = with pkgs; [alejandra];
      in
        lsp ++ fmt;
    };
  };
}
