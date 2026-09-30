local parsers = {
    "lua", "vim", "vimdoc", "query",
    "python", "c", "cpp", "c_sharp",
    "bash", "yaml", "json", "toml",
    "markdown", "markdown_inline", "html", "latex",
    "regex", "diff", "gitcommit",
}

return {
    {
        -- `main` builds parsers with the tree-sitter CLI (installed by run_once_before_02-tools)
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false, -- main doesn't support lazy-loading
        build = ":TSUpdate",
        config = function()
            -- install() is async and a no-op for parsers already present. Headless runs
            -- (the bootstrap's `Lazy! sync`) would quit before it finishes, so wait there.
            local task = require("nvim-treesitter").install(parsers)
            if #vim.api.nvim_list_uis() == 0 then
                task:wait(300000)
            end

            -- main no longer turns highlighting/indent on; start them for any filetype
            -- with an installed parser. Folding is set globally in config/options.lua.
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
                callback = function(args)
                    if not pcall(vim.treesitter.start, args.buf) then
                        return
                    end
                    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
                    if lang and vim.treesitter.query.get(lang, "indents") then
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },
    {
        -- Must track the same branch as nvim-treesitter
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        lazy = false,
        init = function()
            -- python's ftplugin maps ]] / ]m / [[ etc. buffer-locally, which would shadow the
            -- treesitter moves below. Markdown and help keep theirs (heading jumps).
            vim.g.no_python_maps = true
        end,
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = { lookahead = true },
                move = { set_jumps = true },
            })

            local select = require("nvim-treesitter-textobjects.select")
            for keys, spec in pairs({
                af = { "@function.outer", "Around function" },
                ["if"] = { "@function.inner", "Inside function" },
                ac = { "@class.outer", "Around class" },
                ic = { "@class.inner", "Inside class" },
                aa = { "@parameter.outer", "Around argument" },
                ia = { "@parameter.inner", "Inside argument" },
            }) do
                vim.keymap.set({ "x", "o" }, keys, function()
                    select.select_textobject(spec[1], "textobjects")
                end, { desc = spec[2] })
            end

            local move = require("nvim-treesitter-textobjects.move")
            for keys, spec in pairs({
                ["]m"] = { "goto_next_start", "@function.outer", "Next function start" },
                ["]]"] = { "goto_next_start", "@class.outer", "Next class start" },
                ["]M"] = { "goto_next_end", "@function.outer", "Next function end" },
                ["]["] = { "goto_next_end", "@class.outer", "Next class end" },
                ["[m"] = { "goto_previous_start", "@function.outer", "Previous function start" },
                ["[["] = { "goto_previous_start", "@class.outer", "Previous class start" },
                ["[M"] = { "goto_previous_end", "@function.outer", "Previous function end" },
                ["[]"] = { "goto_previous_end", "@class.outer", "Previous class end" },
            }) do
                vim.keymap.set({ "n", "x", "o" }, keys, function()
                    move[spec[1]](spec[2], "textobjects")
                end, { desc = spec[3] })
            end
        end,
    },
}
