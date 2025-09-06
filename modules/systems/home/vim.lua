vim.g.mapleader = " "

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

vim.keymap.set("n", "<leader>w", ":write<CR>")

vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y<CR>')
vim.keymap.set({ "n", "v", "x" }, "<leader>d", '"+d<CR>')
vim.keymap.set({ "n", "v", "x" }, "<leader>s", ':e #<CR>')
vim.keymap.set({ "n", "v", "x" }, "<leader>S", ':sf #<CR>')

-- plugins
vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>")
vim.keymap.set("n", "<leader>g", ":Telescope live_grep<CR>")
vim.keymap.set("n", "<leader>b", ":Telescope buffers<CR>")
vim.keymap.set("n", "<leader>h", ":Telescope help_tags<CR>")

vim.keymap.set("n", "<leader>e", ":Oil<CR>")

-- lsp
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)
-- for vim symbols
vim.lsp.config("lua_ls", { settings = { Lua = { workspace = { library = vim.api.nvim_get_runtime_file("", true) } } } })
vim.lsp.config("nixd", { formatting = { command = { "alejandra" } } })
