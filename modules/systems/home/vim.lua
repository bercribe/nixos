vim.g.mapleader = " "

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- binds
-- convenience
vim.keymap.set({ "n", "v" }, "<leader>w", ":write<CR>")
vim.keymap.set({ "n", "v" }, "<leader>q", ":copen<CR>")
-- system clipboard
vim.keymap.set("n", "<leader>y", '"+yy')
vim.keymap.set("v", "<leader>y", '"+y')
-- black hole delete
vim.keymap.set("n", "<leader>d", '"_dd')
vim.keymap.set("v", "<leader>d", '"_d')
-- switch to alt file
vim.keymap.set({ "n", "v" }, "<leader>a", ":e #<CR>")
vim.keymap.set({ "n", "v" }, "<leader>A", ":sf #<CR>")
-- swap command key
vim.keymap.set({ "n", "v" }, ":", ";")
vim.keymap.set({ "n", "v" }, ";", ":")
-- replace
vim.keymap.set("n", "<leader>r", [[:%s/\V]])
vim.keymap.set("v", "<leader>r", [[<esc>:'<,'>s/\V]])
-- comments
vim.keymap.set("n", "<leader>u", ":norm ^diwx<CR>")
vim.keymap.set("v", "<leader>u", "<esc>:'<,'>norm ^diwx<CR>")

-- plugins
-- fzf-lua
vim.keymap.set({ "n", "v" }, "<leader>f", ":FzfLua files<CR>")
vim.keymap.set("n", "<leader>g", ":FzfLua live_grep<CR>")
vim.keymap.set("v", "<leader>g", ":FzfLua grep_visual<CR>")
vim.keymap.set({ "n", "v" }, "<leader>b", ":FzfLua buffers<CR>")
vim.keymap.set({ "n", "v" }, "<leader>sa", ":FzfLua lsp_code_actions<CR>")
vim.keymap.set({ "n", "v" }, "<leader>sb", ":FzfLua git_blame<CR>")
vim.keymap.set({ "n", "v" }, "<leader>sc", ":FzfLua git_commits<CR>")
vim.keymap.set({ "n", "v" }, "<leader>sC", ":FzfLua git_bcommits<CR>")
vim.keymap.set({ "n", "v" }, "<leader>sg", ":FzfLua grep_cword<CR>")
vim.keymap.set({ "n", "v" }, "<leader>sh", ":FzfLua helptags<CR>")
vim.keymap.set({ "n", "v" }, "<leader>sq", ":FzfLua quickfix<CR>")
vim.keymap.set({ "n", "v" }, "<leader>sr", ":FzfLua registers<CR>")
vim.keymap.set({ "n", "v" }, "<leader>ss", ":FzfLua spell_suggest<CR>")
vim.keymap.set({ "n", "v" }, "<leader>st", ":FzfLua tabs<CR>")
vim.keymap.set({ "n", "v" }, "<leader>su", ":FzfLua lsp_references<CR>")
vim.keymap.set({ "n", "v" }, "<leader>sz", ":FzfLua builtin<CR>")
-- files
vim.keymap.set({ "n", "v" }, "<leader>e", ":Oil<CR>")
vim.keymap.set({ "n", "v" }, "<leader>E", ":Yazi<CR>")
-- typst
vim.keymap.set({ "n", "v" }, "<leader>pt", ":TypstPreview<CR>")

-- scripts
vim.keymap.set({ "n", "v" }, "<leader>xg", ":execute '!gtgh --upstream origin --path \"%\" --line' line('.')<CR>")
vim.keymap.set({ "n", "v" }, "<leader>xG", ":execute '!gtgh --path \"%\" --line' line('.')<CR>")

-- lsp
vim.keymap.set({ "n", "v" }, "<leader>lf", vim.lsp.buf.format)
vim.keymap.set({ "n", "v" }, "<leader>ld", vim.lsp.buf.definition)
vim.keymap.set({ "n", "v" }, "<leader>lt", vim.lsp.buf.type_definition)

-- quickfix binds
vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = "*",
    group = vim.api.nvim_create_augroup("qf", { clear = true }),
    callback = function()
        if vim.bo.buftype == "quickfix" then
            vim.keymap.set("n", "dd", function()
                local idx = vim.fn.line('.')
                local qflist = vim.fn.getqflist()
                table.remove(qflist, idx)
                vim.fn.setqflist(qflist, 'r')
            end, { buffer = true })
        end
    end,
})

-- for vim symbols
vim.lsp.config("lua_ls", { settings = { Lua = { workspace = { library = vim.api.nvim_get_runtime_file("", true) } } } })
vim.lsp.config("nixd", { formatting = { command = { "alejandra" } } })
