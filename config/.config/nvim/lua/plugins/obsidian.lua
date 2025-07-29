vim.wo.conceallevel = 2

return {

    {
        "epwalsh/obsidian.nvim",
        version = "*",
        lazy = true,
        -- ft = "markdown",
        event = {
            -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
            -- refer to `:h file-pattern` for more examples
            "BufReadPre " .. vim.fn.expand "~" .. "/documents/devault/**/*.md",
            "BufNewFile " .. vim.fn.expand "~" .. "/documents/devault/**/*.md",
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        opts = {
            workspaces = {
                {
                    name = "devault",
                    path = "~/documents/devault",
                },
            },

            completion = {
                nvim_cmp = true,
                min_chars = 0
            },

            ui = {
                bullets = {},
            }
        },
    }

}
