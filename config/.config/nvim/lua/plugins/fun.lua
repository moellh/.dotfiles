-- Last modified: 2026-04-10
-- Fun and educational plugins

-- Description: Vim motion games and cellular automaton

-- Git repos:
--   vim-be-good: https://github.com/ThePrimeagen/vim-be-good
--   cellular-automaton: https://github.com/eandrju/cellular-automaton.nvim

return {

    {
        "theprimeagen/vim-be-good",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
    },

    "eandrju/cellular-automaton.nvim",
}
