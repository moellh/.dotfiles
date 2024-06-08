return {

    'tpope/vim-sleuth', -- auto-detect tabstop & shiftwidth

    {
        'numToStr/Comment.nvim',
        opts = {},
        lazy = false,
        -- keymaps:
        -- gcc: toggle comment line
        -- gcb: toggle comment block of code
        -- gc:  toggle comment visual region
        -- gb:  toggle comment visual region as block
    },

    {
        'github/copilot.vim',
        enabled = true,
    },

    'mbbill/undotree',

    {
        'stevearc/aerial.nvim',
        opts = {},
        -- Optional dependencies
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            require('aerial').setup {
                -- optionally use on_attach to set keymaps when aerial has attached to a buffer
                on_attach = function(bufnr)
                    -- Jump forwards/backwards with '{' and '}'
                    vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr })
                    vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr })
                end,
            }
            -- You probably also want to set a keymap to toggle aerial
            vim.keymap.set('n', '<leader>a', '<cmd>AerialToggle!<CR>')
        end,
    },
}
