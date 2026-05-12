return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        keys = {
            { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
            { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Live grep" },
            { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Buffers" },
            { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Help tags" },
            { "<leader>fr", function() require("telescope.builtin").oldfiles() end, desc = "Recent files" },
            { "<leader>fs", function() require("telescope.builtin").lsp_document_symbols() end, desc = "Symbols" },
            { "<leader>/", function() require("telescope.builtin").current_buffer_fuzzy_find() end, desc = "Buffer search" },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                defaults = {
                    file_ignore_patterns = { ".git/", "node_modules/", "%.lock$" },
                    layout_strategy = "horizontal",
                    layout_config = { width = 0.9, height = 0.85, preview_width = 0.55 },
                },
            })
            pcall(telescope.load_extension, "fzf")
        end,
    },
}
