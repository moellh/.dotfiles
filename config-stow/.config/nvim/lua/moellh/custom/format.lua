vim.keymap.set('n', '<leader>f', vim.lsp.buf.format) -- format manually

return {

    {
        'stevearc/conform.nvim',

        opts = {
            notify_on_error = false,

            -- do not format automatically
            --[[ format_on_save = {
                timeout_ms = 3000,
                lsp_fallback = true,
            }, ]]

            formatters_by_ft = {
                lua = { 'stylua' },
                python = { 'isort', 'black' },
                javascript = { { 'prettierd', 'prettier' } },
                java = { 'google-java-format' },
                cpp = { 'clang-format' },
                bash = { 'shfmt' },
            },

            formatters = {
                black = {
                    prepend_args = { '--line-length', '120' },
                },
                ['clang-format'] = {
                    args = {
                        '--style',
                        '{BasedOnStyle: google, ColumnLimit: 120, IndentWidth: 4 }',
                    },
                },
            },
        },
    },

    {
        'zapling/mason-conform.nvim',
        config = function()
            require('mason-conform').setup()
        end,
    },
}
