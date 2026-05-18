return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            flavour = "mocha",
            integrations = {
                cmp = true,
                gitsigns = true,
                telescope = { enabled = true },
                treesitter = true,
                mason = true,
                native_lsp = { enabled = true },
                blink_cmp = true,
            },
        },
        config = function(_, opts)
            require("catppuccin").setup(opts)
            vim.cmd.colorscheme("catppuccin")
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                theme = "catppuccin-nvim",
                globalstatus = true,
                section_separators = "",
                component_separators = "",
            },
        },
    },
    { "nvim-tree/nvim-web-devicons", lazy = true },
}
