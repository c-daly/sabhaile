return {
    {
        "yetone/avante.nvim",
        -- Disabled: requires an Anthropic API key (no OAuth / Max-sub path).
        -- Heavy agent work goes via Claude Code in a tmux pane instead;
        -- flip `enabled = true` if/when an API key is in play.
        enabled = false,
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
    {
        -- claudecode.nvim — bridges nvim to the `claude` CLI via WebSocket MCP.
        -- Configured with provider="none": the plugin runs as server only, exposing
        -- nvim's open buffers / selections / diffs to a claude process launched
        -- externally (e.g., in a tmux pane via `claude --ide`, or with `/ide`
        -- inside an already-running claude session). No managed terminal inside nvim.
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        opts = {
            terminal = { provider = "none" },
        },
        config = true,
        keys = {
            { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Claude: add current buffer to context" },
            { "<leader>cs", "<cmd>ClaudeCodeSend<cr>",        desc = "Claude: send selection", mode = "v" },
            { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>",  desc = "Claude: accept diff" },
            { "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>",    desc = "Claude: deny diff" },
            { "<leader>c?", "<cmd>ClaudeCodeStatus<cr>",      desc = "Claude: IDE socket status" },
        },
    },
}
