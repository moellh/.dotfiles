return {

    {
        'stevearc/conform.nvim',

        opts = {
            notify_on_error = false,

            format_on_save = {
                timeout_ms = 3000,
                lsp_fallback = true,
            },

            formatters_by_ft = {
                lua = { 'stylua' },
                python = { 'isort', 'black' },
                javascript = { { 'prettierd', 'prettier' } },
                -- java = { { 'google-java-format' } },
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
