local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

autocmd("TextYankPost", {
    group = augroup("HighlightYank", { clear = true }),
    callback = function()
        vim.highlight.on_yank({ timeout = 200 })
    end,
})

autocmd("BufReadPost", {
    group = augroup("RestoreCursor", { clear = true }),
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local lcount = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

autocmd("FileType", {
    group = augroup("CloseWithQ", { clear = true }),
    pattern = { "help", "qf", "checkhealth", "lspinfo", "man" },
    callback = function(args)
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true })
    end,
})

-- Auto-reload files changed on disk when the buffer regains focus.
-- Pairs with claudecode.nvim so external claude edits land live in the buffer.
autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
    group = augroup("AutoCheckTime", { clear = true }),
    command = "checktime",
})
