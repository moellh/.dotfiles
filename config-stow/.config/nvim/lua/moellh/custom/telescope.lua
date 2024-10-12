return {

    { -- fuzzy finder
        'nvim-telescope/telescope.nvim',

        event = 'VeryLazy', -- after nvim started

        dependencies = {
            'nvim-lua/plenary.nvim', -- async operations

            { -- fzf
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make',
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            },

            'nvim-telescope/telescope-ui-select.nvim', -- nvim uses telescope ui
            'nvim-tree/nvim-web-devicons', -- icons
        },

        config = function()
            require('telescope').setup { -- see `:help telescope.setup()`
                extensions = {
                    ['ui-select'] = {
                        require('telescope.themes').get_dropdown(),
                    },
                },
            }

            pcall(require('telescope').load_extension, 'fzf')
            pcall(require('telescope').load_extension, 'ui-select')

            -- see `:help telescope.builtin`
            local builtin = require 'telescope.builtin'
            vim.keymap.set(
                'n',
                '<leader>sh',
                builtin.help_tags,
                { desc = 'search help' }
            )
            vim.keymap.set(
                'n',
                '<leader>sk',
                builtin.keymaps,
                { desc = 'search keymaps' }
            )
            vim.keymap.set(
                'n',
                '<leader>sf',
                builtin.find_files,
                { desc = 'search files' }
            )
            vim.keymap.set(
                'n',
                '<leader>st',
                builtin.builtin,
                { desc = 'search telescope' }
            )
            vim.keymap.set(
                'n',
                '<leader>sw',
                builtin.grep_string,
                { desc = 'search current word' }
            )
            vim.keymap.set(
                'n',
                '<leader>sg',
                builtin.live_grep,
                { desc = 'search by grep' }
            )
            vim.keymap.set(
                'n',
                '<leader>sd',
                builtin.diagnostics,
                { desc = 'search diagnostics' }
            )
            vim.keymap.set(
                'n',
                '<leader>sr',
                builtin.resume,
                { desc = 'search resume' }
            )
            vim.keymap.set(
                'n',
                '<leader>s.',
                builtin.oldfiles,
                { desc = 'search recent files' }
            )
            vim.keymap.set(
                'n',
                '<leader><leader>',
                builtin.buffers,
                { desc = 'find existing buffers' }
            )

            vim.keymap.set('n', '<C-p>', builtin.git_files, {})
            vim.keymap.set('n', '<leader>pws', function()
                local word = vim.fn.expand '<cword>'
                builtin.grep_string { search = word }
            end)
            vim.keymap.set('n', '<leader>pWs', function()
                local word = vim.fn.expand '<cWORD>'
                builtin.grep_string { search = word }
            end)
            vim.keymap.set('n', '<leader>ps', function()
                builtin.grep_string { search = vim.fn.input 'Grep > ' }
            end)

            vim.keymap.set('n', '<leader>/', function()
                builtin.current_buffer_fuzzy_find(
                    require('telescope.themes').get_dropdown {
                        winblend = 10,
                        previewer = false,
                    }
                )
            end, { desc = 'fuzzily search current buffer' })

            vim.keymap.set('n', '<leader>s/', function()
                builtin.live_grep {
                    grep_open_files = true,
                    prompt_title = 'live grep in open files',
                }
            end, { desc = 'search in open files' })

            vim.keymap.set('n', '<leader>sn', function()
                builtin.find_files { cwd = vim.fn.stdpath 'config' }
            end, { desc = 'search neovim config' })
        end,
    },
}
