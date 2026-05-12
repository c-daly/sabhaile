return {
    {
        "saghen/blink.cmp",
        event = "InsertEnter",
        version = "*",
        dependencies = {
            { "L3MON4D3/LuaSnip", version = "v2.*", build = "make install_jsregexp" },
            "rafamadriz/friendly-snippets",
        },
        opts = {
            keymap = { preset = "default" },
            appearance = { nerd_font_variant = "mono" },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
            snippets = { preset = "luasnip" },
            completion = {
                accept = { auto_brackets = { enabled = true } },
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
            },
            signature = { enabled = true },
        },
    },
}
