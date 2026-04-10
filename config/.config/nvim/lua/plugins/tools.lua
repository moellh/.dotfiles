-- Last modified: 2026-04-10
-- Utility and tool plugins

-- Description: Devicons, kitty, todo-comments, mini.nvim, colorizer, tmux nav, latex, sidekick, trouble, obsession

-- Git repos:
--   nvim-web-devicons: https://github.com/nvim-tree/nvim-web-devicons
--   vim-kitty: https://github.com/fladson/vim-kitty
--   todo-comments: https://github.com/folke/todo-comments.nvim
--   mini.nvim: https://github.com/echasnovski/mini.nvim
--   nvim-nio: https://github.com/nvim-neotest/nvim-nio
--   nvim-colorizer: https://github.com/catgoose/nvim-colorizer.lua
--   nvim-tmux-navigation: https://github.com/alexghergh/nvim-tmux-navigation
--   vimtex: https://github.com/lervag/vimtex
--   sidekick: https://github.com/folke/sidekick.nvim
--   trouble.nvim: https://github.com/folke/trouble.nvim
--   vim-obsession: https://github.com/tpope/vim-obsession

vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww ts<CR>")

return {

    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
    },

    "fladson/vim-kitty",

    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            signs = true,
            sign_priority = 8,
            keywords = {
                FIX = { icon = "", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
                TODO = { icon = "", color = "info" },
                HACK = { icon = "", color = "warning" },
                WARN = { icon = "", color = "warning", alt = { "WARNING", "XXX" } },
                PERF = { icon = "", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = "", color = "hint", alt = { "INFO" } },
                TEST = { icon = "", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
            },
            gui_style = { fg = "NONE", bg = "BOLD" },
            merge_keywords = true,
            highlight = {
                multiline = false,
                multiline_pattern = "^.",
                multiline_context = 10,
                before = "",
                keyword = "wide",
                after = "fg",
                pattern = [[.*<(KEYWORDS)\s*:]],
                comments_only = false,
                max_line_len = 400,
                exclude = {},
            },
            colors = {
                error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
                warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
                info = { "DiagnosticInfo", "#2563EB" },
                hint = { "DiagnosticHint", "#10B981" },
                default = { "Identifier", "#7C3AED" },
                test = { "Identifier", "#FF00FF" },
            },
            search = {
                command = "rg",
                args = { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column" },
            },
        },
    },

    {
        "echasnovski/mini.nvim",
        config = function()
            require("mini.ai").setup { n_lines = 500 }
        end,
    },

    "nvim-neotest/nvim-nio",

    {
        "catgoose/nvim-colorizer.lua",
        opts = {
            filetypes = {},
            parsers = { css = true, tailwind = { enable = true } },
            display = { mode = "virtualtext", virtualtext = { position = "eol" } },
        },
    },

    {
        "alexghergh/nvim-tmux-navigation",
        config = function()
            local nvim_tmux_nav = require "nvim-tmux-navigation"
            nvim_tmux_nav.setup { disable_when_zoomed = true }
            vim.keymap.set("n", "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
            vim.keymap.set("n", "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
            vim.keymap.set("n", "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
            vim.keymap.set("n", "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
            vim.keymap.set("n", "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
            vim.keymap.set("n", "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)
        end,
    },

    {
        "lervag/vimtex",
        lazy = false,
        init = function()
            vim.g.vimtex_view_general_viewer = 'okular'
            vim.g.vimtex_view_general_options = '--unique file:@pdf\\#src:@line@tex'
            vim.g.vimtex_quickfix_mode = 0
        end,
        keys = {
            { "<leader>rl", "<Plug>(vimtex-compile)" },
            { "<leader>lv", "<Plug>(vimtex-view)" },
        },
    },

    {
        "folke/sidekick.nvim",
        lazy = false,
        dependencies = { "zbirenbaum/copilot.lua" },
        opts = {
            cli = { mux = { backend = "tmux", enabled = true } },
        },
        keys = {
            {
                "<tab>",
                function()
                    if not require("sidekick").nes_jump_or_apply() then
                        return "<Tab>"
                    end
                    return ""
                end,
                expr = true,
                mode = { "i", "n" },
                desc = "Goto/Apply Next Edit Suggestion",
            },
            { "<leader>aa", function() require("sidekick.cli").toggle({ name = "opencode" }) end, desc = "Sidekick Toggle Opencode" },
            { "<leader>at", function() require("sidekick.cli").send { msg = "{this}" } end, mode = { "x", "n" }, desc = "Send This to Opencode" },
            { "<leader>af", function() require("sidekick.cli").send { msg = "{file}" } end, desc = "Send File to Opencode" },
            { "<leader>av", function() require("sidekick.cli").send { msg = "{selection}" } end, mode = { "x" }, desc = "Send Visual Selection to Opencode" },
            { "<leader>ap", function() require("sidekick.cli").prompt() end, mode = { "n", "x" }, desc = "Sidekick Select Prompt" },
        },
    },

    {
        "folke/trouble.nvim",
        opts = {},
        cmd = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
            { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
            { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions / references / ... (Trouble)" },
            { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
            { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
        },
    },

    "tpope/vim-obsession",
}
