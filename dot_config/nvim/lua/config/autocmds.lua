local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

autocmd("TextYankPost", {
    group = augroup("HighlightYank", { clear = true }),
    callback = function()
        vim.hl.on_yank({ timeout = 200 })
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

-- Reload files changed on disk (e.g. edited by Claude Code in another tmux pane).
-- 'autoread' is on by default but only acts when Nvim checks timestamps. Check on
-- focus / buffer switch, and every second while in Normal mode so edits show up
-- even when you're just watching (CursorHold fires once per idle, so it can't do this).
-- Skipped in the command-line window (q:), where checktime errors with E11.
local function checktime()
    if vim.fn.getcmdwintype() == "" and vim.api.nvim_get_mode().mode == "n" then
        vim.cmd("checktime")
    end
end
autocmd({ "FocusGained", "BufEnter", "TermLeave" }, {
    group = augroup("AutoCheckTime", { clear = true }),
    callback = checktime,
})
vim.uv.new_timer():start(1000, 1000, vim.schedule_wrap(checktime))

autocmd("FileChangedShellPost", {
    group = augroup("NotifyReload", { clear = true }),
    callback = function(args)
        vim.notify("Reloaded " .. vim.fn.fnamemodify(args.file, ":~:."), vim.log.levels.INFO)
    end,
})
