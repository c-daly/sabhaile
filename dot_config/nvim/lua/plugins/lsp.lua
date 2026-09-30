return {
    {
        "mason-org/mason.nvim",
        cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonInstallAll" },
        build = ":MasonUpdate",
        opts = {
            ui = { border = "rounded" },
            registries = {
                "github:mason-org/mason-registry",
                "github:Crashdummyy/mason-registry",
            },
        },
    },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
        event = { "BufReadPre", "BufNewFile" },
        opts = {},
    },
    {
        -- Every Mason package, installed in the background on startup if missing. One list
        -- covers what mason-lspconfig can't: roslyn (not an lspconfig server, comes from the
        -- Crashdummyy registry above), formatters and debug adapters. The bootstrap
        -- (run_once_after_04-nvim) runs :MasonToolsInstallSync against the same list.
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "mason-org/mason.nvim" },
        event = "VeryLazy",
        cmd = { "MasonToolsInstall", "MasonToolsInstallSync", "MasonToolsUpdate", "MasonToolsClean" },
        opts = {
            ensure_installed = {
                -- language servers
                "basedpyright", "ruff", "clangd", "roslyn",
                "typescript-language-server", "lua-language-server",
                "json-lsp", "yaml-language-server", "bash-language-server", "marksman",
                -- formatters (conform.nvim)
                "stylua", "prettierd", "shfmt",
                -- debug adapters (nvim-dap)
                "debugpy", "netcoredbg",
            },
        },
        config = function(_, opts)
            local mti = require("mason-tool-installer")
            mti.setup(opts)
            -- Its own startup check hangs off VimEnter, which has already fired by VeryLazy.
            -- Loaded before VimEnter (the bootstrap's :MasonToolsInstallSync), leave it be:
            -- a second, async check racing the sync one can leave the sync one waiting forever.
            if vim.v.vim_did_enter == 1 then
                mti.run_on_start()
            end
        end,
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local ok, blink = pcall(require, "blink.cmp")
            if ok then
                capabilities = blink.get_lsp_capabilities(capabilities)
            end

            local on_attach = function(_, buffer)
                local map = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
                end
                map("n", "gd", vim.lsp.buf.definition, "Goto definition")
                map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
                map("n", "gi", vim.lsp.buf.implementation, "Goto implementation")
                map("n", "K", vim.lsp.buf.hover, "Hover")
                map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
                map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
                map("n", "<leader>F", function() vim.lsp.buf.format({ async = true }) end, "Format")
            end

            local servers = {
                basedpyright = {
                    settings = {
                        basedpyright = {
                            analysis = {
                                typeCheckingMode = "standard",
                                autoImportCompletions = true,
                            },
                        },
                    },
                },
                ruff = {},
                clangd = {
                    cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
                },
                ts_ls = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            workspace = { checkThirdParty = false },
                            telemetry = { enable = false },
                            diagnostics = { globals = { "vim" } },
                        },
                    },
                },
                jsonls = {},
                yamlls = {},
                bashls = {},
                marksman = {},
            }

            vim.lsp.config('*', {
                capabilities = capabilities,
                on_attach = on_attach,
            })

            for name, config in pairs(servers) do
                vim.lsp.config(name, config)
            end
            vim.lsp.enable(vim.tbl_keys(servers))

            vim.diagnostic.config({
                virtual_text = { spacing = 4, prefix = "●" },
                severity_sort = true,
                float = { border = "rounded" },
            })
        end,
    },
}
