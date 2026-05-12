return {
    {
        "seblyng/roslyn.nvim",
        ft = { "cs", "razor" },
        dependencies = { "tris203/rzls.nvim" },
        opts = {
            args = { "--logLevel=Information", "--extensionLogDirectory=" .. vim.fn.stdpath("log") },
        },
    },
}
