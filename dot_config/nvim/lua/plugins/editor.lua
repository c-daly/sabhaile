return {
    { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },
    { "numToStr/Comment.nvim", event = "VeryLazy", opts = {} },
    { "echasnovski/mini.pairs", event = "InsertEnter", opts = {} },
    { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
    {
        -- Same <C-h/j/k/l> moves between Nvim splits and tmux panes (tmux side in ~/.tmux.conf)
        "christoomey/vim-tmux-navigator",
        cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight", "TmuxNavigatePrevious" },
        keys = {
            { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Window/pane left" },
            { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Window/pane down" },
            { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Window/pane up" },
            { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Window/pane right" },
        },
    },
}
