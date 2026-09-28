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
            { "<leader>fR", function() require("telescope.builtin").resume() end, desc = "Resume last picker" },
            { "<leader>fd", function() require("telescope.builtin").diagnostics() end, desc = "Diagnostics" },
            { "<leader>fw", function() require("telescope.builtin").grep_string() end, desc = "Grep word under cursor" },
            { "<leader>fu", function() require("telescope.builtin").lsp_references() end, desc = "LSP references (usages)" },
            { "<leader>fk", function() require("telescope.builtin").keymaps() end, desc = "Keymaps" },
            { "<leader>gs", function() require("telescope.builtin").git_status() end, desc = "Git status" },
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
