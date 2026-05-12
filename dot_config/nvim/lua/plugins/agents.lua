return {
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        version = false,
        build = "make",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
            "stevearc/dressing.nvim",
        },
        opts = {
            provider = "claude",
            providers = {
                claude = {
                    endpoint = "https://api.anthropic.com",
                    model = "claude-sonnet-4-6",
                    extra_request_body = {
                        temperature = 0,
                        max_tokens = 8192,
                    },
                },
            },
            behaviour = {
                auto_suggestions = false,
                auto_set_highlight_group = true,
                auto_set_keymaps = true,
                auto_apply_diff_after_generation = false,
                support_paste_from_clipboard = true,
            },
            mappings = {
                ask = "<leader>aa",
                edit = "<leader>ae",
                refresh = "<leader>ar",
                focus = "<leader>af",
                toggle = {
                    default = "<leader>at",
                    debug = "<leader>ad",
                    hint = "<leader>ah",
                },
            },
        },
    },
}
