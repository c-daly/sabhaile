return {
    {
        "stevearc/oil.nvim",
        lazy = false,
        keys = {
            { "-", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" },
        },
        opts = {
            default_file_explorer = true,
            view_options = {
                show_hidden = true,
            },
            keymaps = {
                ["g?"] = "actions.show_help",
                ["<CR>"] = "actions.select",
                ["<C-v>"] = { "actions.select", opts = { vertical = true } },
                ["<C-x>"] = { "actions.select", opts = { horizontal = true } },
                ["<C-p>"] = "actions.preview",
                ["<C-c>"] = "actions.close",
                ["-"] = "actions.parent",
                ["_"] = "actions.open_cwd",
                ["gs"] = "actions.change_sort",
                ["g."] = "actions.toggle_hidden",
            },
        },
    },
}
