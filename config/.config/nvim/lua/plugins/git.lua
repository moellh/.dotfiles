-- Last modified: 2026-04-10
-- Git integration plugins

-- Description: Git signs in gutter, hunk navigation, lazygit terminal

-- Git repos:
--   gitsigns: https://github.com/lewis6991/gitsigns.nvim
--   lazygit: https://github.com/kdheepak/lazygit.nvim

return {

    {
        'lewis6991/gitsigns.nvim',
        opts = {
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
        },
    },
    {
        'kdheepak/lazygit.nvim',
    }
}
