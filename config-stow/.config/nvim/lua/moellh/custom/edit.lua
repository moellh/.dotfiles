-- Move selected text up/down one line
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- scroll in center
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Move lines up and down
vim.keymap.set({ 'n', 'v' }, '<leader>d', [["_d]])

-- Select current token for substitution with same token as preselected text
vim.keymap.set(
    'n',
    '<leader>s',
    [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]
)

return { -- lazy loading plugins

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

    {
        'mbbill/undotree',

        config = function()
            vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
        end,
    },

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
                    vim.keymap.set(
                        'n',
                        '{',
                        '<cmd>AerialPrev<CR>',
                        { buffer = bufnr }
                    )
                    vim.keymap.set(
                        'n',
                        '}',
                        '<cmd>AerialNext<CR>',
                        { buffer = bufnr }
                    )
                end,
            }
            -- You probably also want to set a keymap to toggle aerial
            vim.keymap.set('n', '<leader>a', '<cmd>AerialToggle!<CR>')
        end,
    },
}
