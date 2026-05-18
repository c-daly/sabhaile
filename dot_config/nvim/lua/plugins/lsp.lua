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
        opts = {
            ensure_installed = {
                "basedpyright", "ruff",
                "clangd",
                "ts_ls",
                "lua_ls",
                "jsonls", "yamlls", "bashls", "marksman",
            },
            automatic_installation = true,
        },
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
                map("n", "gr", vim.lsp.buf.references, "References")
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
