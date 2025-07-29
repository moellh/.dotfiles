
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('moellh', {}),
    callback = function(e)
        local opts = { buffer = e.buf }

        -- show diagnostics of current line
        vim.keymap.set('n', '<leader>ll', function()
            vim.diagnostic.open_float()
        end, {
            buffer = e.buf,
            desc = "Show diagnostics of current line",
        })

    end
})

vim.diagnostic.config {
    -- update_in_insert = true,
    float = {
        focusable = false,
        style = 'minimal',
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
    },
}

return {}
