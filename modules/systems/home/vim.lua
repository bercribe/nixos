vim.g.mapleader = " "

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.keymap.set("n", "<leader>w", ":write<CR>")

vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y<CR>')
vim.keymap.set({ "n", "v", "x" }, "<leader>d", '"+d<CR>')
vim.keymap.set({ "n", "v", "x" }, "<leader>s", ':e #<CR>')
vim.keymap.set({ "n", "v", "x" }, "<leader>S", ':sf #<CR>')

-- plugins
vim.keymap.set("n", "<leader>f", ":FzfLua files<CR>")
vim.keymap.set("n", "<leader>G", ":FzfLua live_grep<CR>")
vim.keymap.set("n", "<leader>b", ":FzfLua buffers<CR>")
vim.keymap.set("n", "<leader>h", ":FzfLua helptags<CR>")

vim.keymap.set("n", "<leader>e", ":Oil<CR>")
vim.keymap.set("n", "<leader>E", ":Yazi<CR>")

vim.keymap.set("n", "<leader>tp", ":TypstPreview<CR>")

vim.keymap.set("n", "<leader>gu", ":execute '!gtgh %' line('.')<CR>")

-- lsp
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)
-- for vim symbols
vim.lsp.config("lua_ls", { settings = { Lua = { workspace = { library = vim.api.nvim_get_runtime_file("", true) } } } })
vim.lsp.config("nixd", { formatting = { command = { "alejandra" } } })
