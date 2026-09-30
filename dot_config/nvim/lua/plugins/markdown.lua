return {
    {
        "OXY2DEV/markview.nvim",
        -- Markview defers its own work to markdown buffers; its README asks not to lazy-load it.
        lazy = false,
        opts = {
            preview = {
                icon_provider = "devicons",
            },
        },
        keys = {
            { "<leader>um", "<cmd>Markview toggle<cr>", ft = "markdown", desc = "Toggle markdown preview" },
            { "<leader>us", "<cmd>Markview splitToggle<cr>", ft = "markdown", desc = "Toggle markdown preview split" },
        },
    },
}
