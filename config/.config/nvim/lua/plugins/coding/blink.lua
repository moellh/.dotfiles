-- Last modified: 2026-04-10
-- Enabled blink.cmp for autocompletion with builtin snippets

-- Git repo: https://github.com/Saghen/blink.cmp

return {
    {
        "saghen/blink.cmp",
        version = "1.*",
        build = "cargo build --release",
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            -- Rust fuzzy matching for performance
            fuzzy = { implementation = "prefer_rust" },

            -- Keymap configuration
            keymap = {
                preset = "default",
                -- Add any custom keymaps here
                ["<Tab>"] = { "snippet_forward", "fallback" },
                ["<C-d>"] = { "show_documentation", "hide_documentation" },
            },

            -- Completion menu with auto docs
            completion = {
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 500,
                },
            },

            -- Completion sources
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },

            -- Snippets: use builtin preset (NOT luasnip)
            snippets = {
                preset = "default",
            },
        },
    },
}
