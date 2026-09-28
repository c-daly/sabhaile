vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local map = vim.keymap.set

map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Quit all (force)" })

map("n", "Y", "y$", { desc = "Yank to end of line" })
map("n", "n", "nzzzv", { desc = "Next match centered" })
map("n", "N", "Nzzzv", { desc = "Prev match centered" })
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

map("v", "<", "<gv")
map("v", ">", ">gv")
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- <C-h/j/k/l> window + tmux pane navigation lives in plugins/editor.lua (vim-tmux-navigator)

map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear highlight" })

map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic float" })

map("n", "<leader>uh", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { desc = "Toggle inlay hints" })
map("n", "<leader>uu", "<cmd>Undotree<cr>", { desc = "Undo tree" })

map("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Close buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
