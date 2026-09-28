return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        -- The master branch doesn't support Nvim 0.12 (moving to `main` is in BACKLOG.md).
        -- It registers its query directives/predicates with { all = false } (one node
        -- per capture); 0.12 ignores that option and passes node lists, so e.g. markdown
        -- code fences error on open. Restore the old contract: hand those handlers the
        -- last node of each capture. Runs at startup, before the plugin registers them.
        init = function()
            if vim.fn.has("nvim-0.12") == 0 then
                return
            end
            local query = vim.treesitter.query
            for _, name in ipairs({ "add_directive", "add_predicate" }) do
                local register = query[name]
                query[name] = function(query_name, handler, opts)
                    if type(opts) == "table" and opts.all == false then
                        local inner = handler
                        handler = function(match, ...)
                            local single = {}
                            for id, nodes in pairs(match) do
                                single[id] = type(nodes) == "table" and nodes[#nodes] or nodes
                            end
                            return inner(single, ...)
                        end
                    end
                    return register(query_name, handler, opts)
                end
            end
        end,
        dependencies = {
            -- Must track the same branch as nvim-treesitter (master API: textobjects = {...} below)
            { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
        },
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
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = { query = "@function.outer", desc = "Around function" },
                            ["if"] = { query = "@function.inner", desc = "Inside function" },
                            ["ac"] = { query = "@class.outer", desc = "Around class" },
                            ["ic"] = { query = "@class.inner", desc = "Inside class" },
                            ["aa"] = { query = "@parameter.outer", desc = "Around argument" },
                            ["ia"] = { query = "@parameter.inner", desc = "Inside argument" },
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
                        goto_next_end = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
                        goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
                        goto_previous_end = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
                    },
                },
            })
        end,
    },
}
