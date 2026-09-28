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
                local line_range = function() return { vim.fn.line("."), vim.fn.line("v") } end

                map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
                map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")
                map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
                map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
                map("v", "<leader>hs", function() gs.stage_hunk(line_range()) end, "Stage selected lines")
                map("v", "<leader>hr", function() gs.reset_hunk(line_range()) end, "Reset selected lines")
                map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
                map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
                map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
                map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
                map("n", "<leader>hd", gs.diffthis, "Diff against index")
                map("n", "<leader>ub", gs.toggle_current_line_blame, "Toggle inline blame")
                map({ "o", "x" }, "ih", gs.select_hunk, "Hunk text object")
            end,
        },
    },
    { "tpope/vim-fugitive", cmd = { "Git", "Gvdiffsplit", "Gdiffsplit", "Gwrite", "Gread" } },
}
