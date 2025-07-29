-- Visual Block mode treats out-of-file cells as spaces
vim.opt.virtualedit = 'block'

-- keep selection when shifting
vim.keymap.set('v', '<', '<gv', { desc = 'Shift left, Keep selection' })
vim.keymap.set('v', '>', '>gv', { desc = 'Shift right, Keep selection' })

return {
    -- no plugins so far
}
