-- using xclip to copy to system clipboard

-- y,p use "+ register (system clipboard by default)
vim.opt.clipboard = 'unnamedplus'

-- highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight yanked text',
    group = 'moellh',
    callback = function()
        vim.highlight.on_yank()
    end,
})

return {
    -- no plugins so far
}
