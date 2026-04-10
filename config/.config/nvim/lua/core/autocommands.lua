-- Last modified: 2026-04-10
-- No modifications necessary

-- Description: Core autocommands - yank highlight, trailing whitespace removal

-- No external plugin - native vim configuration

-- Highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight yanked text',
    group = vim.api.nvim_create_augroup('moellh-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Remove trailing whitespaces on write without moving cursor
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    group = vim.api.nvim_create_augroup('moellh-trim', { clear = true }),
    pattern = "*",
    callback = function()
        local view = vim.fn.winsaveview()
        vim.cmd [[%s/\s\+$//e]]
        vim.fn.winrestview(view)
    end,
})
