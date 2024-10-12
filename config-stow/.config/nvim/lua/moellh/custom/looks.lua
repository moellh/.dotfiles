return {

    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 1000,
        config = function()
            vim.cmd.colorscheme 'catppuccin-mocha'
        end,
    },

    {
        'yorik1984/newpaper.nvim',
        style = 'light',
    },

    { -- indentation guides even on blank lines
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        opts = {},
    },

    -- 'nvim-treesitter/nvim-treesitter-context',

    'folke/twilight.nvim',

    {
        'folke/zen-mode.nvim',
        config = function()
            vim.keymap.set('n', '<leader>zz', function()
                require('zen-mode').setup {
                    window = {
                        width = 80,
                        options = {},
                    },
                }
                require('zen-mode').toggle()
                vim.wo.wrap = false
                vim.wo.number = false
                vim.wo.rnu = false
                vim.opt.list = false
                vim.opt.scrolloff = 0
                vim.opt.colorcolumn = ''
            end)
        end,
    },

    'j-hui/fidget.nvim',
}
