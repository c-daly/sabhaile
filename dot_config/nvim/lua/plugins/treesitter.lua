return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "lua", "vim", "vimdoc", "query",
                    "python", "c", "cpp", "c_sharp",
                    "bash", "yaml", "json", "toml",
                    "markdown", "markdown_inline",
                    "regex", "diff", "gitcommit",
                },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },
}
