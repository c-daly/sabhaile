return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "" },
                changedelete = { text = "▎" },
            },
            on_attach = function(buffer)
                local gs = require("gitsigns")
                local map = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
                end
                map("n", "]h", gs.next_hunk, "Next hunk")
                map("n", "[h", gs.prev_hunk, "Prev hunk")
                map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
                map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
                map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
                map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
            end,
        },
    },
    { "tpope/vim-fugitive", cmd = { "Git", "Gvdiff", "Gblame", "Gwrite", "Gread" } },
}
