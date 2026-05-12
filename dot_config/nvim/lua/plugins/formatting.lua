return {
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "ruff_format", "ruff_fix" },
                c = { "clang-format" },
                cpp = { "clang-format" },
                json = { "prettierd", "prettier" },
                yaml = { "prettierd", "prettier" },
                markdown = { "prettierd", "prettier" },
                sh = { "shfmt" },
            },
            format_on_save = function(bufnr)
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return nil
                end
                return { timeout_ms = 1500, lsp_format = "fallback" }
            end,
        },
        init = function()
            vim.api.nvim_create_user_command("FormatToggle", function()
                vim.g.disable_autoformat = not vim.g.disable_autoformat
                print("Format-on-save: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
            end, { desc = "Toggle format-on-save" })
        end,
    },
}
