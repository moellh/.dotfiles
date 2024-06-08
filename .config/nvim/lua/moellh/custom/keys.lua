return {

    { -- show pending keybinds
        'folke/which-key.nvim',
        event = 'VeryLazy',
        config = function()
            require('which-key').setup()

            require('which-key').register {
                -- ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
            }
        end,
    },
}
