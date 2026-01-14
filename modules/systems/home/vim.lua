vim.g.mapleader = " "

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
-- this doesn't reliably get set in tmux sessions over ssh
vim.o.termguicolors = true;

-- binds
-- convenience
vim.keymap.set({ "n", "v" }, "<leader>w", ":write<CR>")
vim.keymap.set({ "n", "v" }, "<leader>q", ":copen<CR>")
-- system clipboard
vim.keymap.set("n", "<leader>y", '"+yy')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set({"n", "v"}, "<leader>p", '"+p')
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
vim.keymap.set("v", "<leader>r", [[:s/\V]])
-- comments
vim.keymap.set({ "n", "v" }, "<leader>u", ":norm ^diwx<CR>")
-- indent pasted lines
vim.keymap.set("n", "<leader>[", "'[V']<")
vim.keymap.set("n", "<leader>]", "'[V']>")

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
vim.keymap.set({ "n", "v" }, "<leader>Pt", ":TypstPreview<CR>")

-- scripts
vim.keymap.set({ "n", "v" }, "<leader>xg", ":execute '!gtgh --upstream origin --path \"%\" --line' line('.')<CR>")
vim.keymap.set({ "n", "v" }, "<leader>xG", ":execute '!gtgh --path \"%\" --line' line('.')<CR>")

-- lsp
vim.keymap.set({ "n", "v" }, "<leader>lf", vim.lsp.buf.format)
vim.keymap.set({ "n", "v" }, "<leader>ld", vim.lsp.buf.definition)
vim.keymap.set({ "n", "v" }, "<leader>lt", vim.lsp.buf.type_definition)

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp", {}),
    callback = function(e)
        local name = vim.lsp.get_client_by_id(e.data.client_id).name
        if name == "clangd" then
            vim.keymap.set({ "n", "v" }, "<leader>la", ":LspClangdSwitchSourceHeader<CR>", { buffer = true })
        end
    end
})

-- quickfix binds
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("qf", {}),
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

-- debugger
local dap = require("dap")
vim.keymap.set("n", "<leader>dn", ":DapNew<CR>")
vim.keymap.set("n", "<leader>dt", dap.terminate)
vim.keymap.set("n", "<leader>dr", dap.restart)
vim.keymap.set("n", "<leader>dR", dap.run_last)
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>dl", function() dap.set_breakpoint(nil, nil, vim.fn.input("log point message: ")) end)
vim.keymap.set("n", "<leader>dc", dap.continue)
vim.keymap.set({"n", "v"}, "<leader>dh", require("dap.ui.widgets").hover)
vim.keymap.set("n", "<leader>dv", ":DapViewToggle<CR>")
vim.keymap.set("n", "<leader>dV", dap.repl.toggle)

-- TODO remove when on_session config is verified
vim.keymap.set("n", "<leader><Down>", dap.step_over)
vim.keymap.set("n", "<leader><Right>", dap.step_into)
vim.keymap.set("n", "<leader><Left>", dap.step_out)
vim.keymap.set("n", "<leader><Up>", dap.restart_frame)
if not dap.listeners.on_session then
    dap.listeners.on_session = {}
end
dap.listeners.on_session["keymaps-and-dapview"] = function(old, new)
    local dapview = require("dap-view")
    if new and not old then
        dapview.open()
        vim.keymap.set("n", "<Down>", dap.step_over)
        vim.keymap.set("n", "<Right>", dap.step_into)
        vim.keymap.set("n", "<Left>", dap.step_out)
        vim.keymap.set("n", "<Up>", dap.restart_frame)
    elseif old and not new then
        dapview.close()
        vim.keymap.del("n", "<Down>")
        vim.keymap.del("n", "<Right>")
        vim.keymap.del("n", "<Left>")
        vim.keymap.del("n", "<Up>")
    end
end
