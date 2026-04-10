-- Last modified: 2026-04-10
-- Copilot configured for inline suggestions

-- Git repo: https://github.com/zbirenbaum/copilot.lua

return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
        require("copilot").setup {
            suggestion = {
                enabled = true,
                auto_trigger = true,
                debounce = 75,
                keymap = {
                    accept = "<C-l>",
                    accept_word = false,
                    accept_line = false,
                    next = "<C-j>",
                    prev = "<C-k>",
                    dismiss = "<C-h>",
                },
            },
            panel = { enabled = false },
        }

        -- Make copilot suggestions look different (grayed out, italic)
        vim.api.nvim_set_hl(0, "CopilotSuggestion", {
            fg = "#6c7086",  -- Catppuccin surface2 color
            ctermfg = 244,
            italic = true,
        })
    end,
}
