-- Last modified: 2026-04-10
-- Git integration plugins

-- Description: Git signs in gutter, hunk navigation, lazygit terminal, diff review

-- Git repos:
--   gitsigns: https://github.com/lewis6991/gitsigns.nvim
--   lazygit: https://github.com/kdheepak/lazygit.nvim
--   codediff: https://github.com/esmuellert/codediff.nvim

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
            -- jupytext.nvim shows .ipynb files as text, gitsigns would diff
            -- that text against the JSON in git
            on_attach = function(bufnr)
                if vim.api.nvim_buf_get_name(bufnr):match('%.ipynb$') then
                    return false
                end
            end,
        },
    },
    {
        'kdheepak/lazygit.nvim',
        keys = {
            { '<leader>lg', '<cmd>LazyGit<CR>', desc = 'LazyGit' },
        },
    },
    {
        'esmuellert/codediff.nvim',
        cmd = 'CodeDiff',
        keys = {
            { '<leader>gd', '<cmd>CodeDiff<CR>', desc = 'Git diff (working tree)' },
            { '<leader>gh', '<cmd>CodeDiff history %<CR>', desc = 'Git history (current file)' },
        },
        opts = {
            keymaps = {
                view = {
                    -- defaults <leader>b / <leader>e shadow dap breakpoint and nvim-tree
                    toggle_explorer = '<leader>gb',
                    focus_explorer = '<leader>ge',
                },
            },
        },
    },
}
