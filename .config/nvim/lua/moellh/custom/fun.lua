vim.keymap.set('n', '<leader>mr', '<cmd>CellularAutomaton make_it_rain<CR>')

return {

    -- learn vim motions
    {
        'theprimeagen/vim-be-good',

        dependencies = {
            'nvim-lua/plenary.nvim',
        },

        config = function() end,
    },

    'eandrju/cellular-automaton.nvim',
}
