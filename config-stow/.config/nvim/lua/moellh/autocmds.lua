local augroup = vim.api.nvim_create_augroup
local moellh_group = vim.api.nvim_create_augroup('moellh', {})

-- yanking displays short highlight of selected text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight yanked text',
    group = vim.api.nvim_create_augroup('yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- remove trailing whitespaces on write
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    group = 'moellh',
    pattern = '*',
    command = [[%s/\s\+$//e]],
})
