vim.g.netrw_banner = 0

-- Make current file executable
vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true })

return {}
