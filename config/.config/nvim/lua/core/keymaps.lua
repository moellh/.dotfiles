-- Last modified: 2026-04-10
-- No modifications necessary

-- Description: Core keymaps - quickfix/location lists, search, clipboard, selection, editing

-- No external plugin - native vim configuration

-- System clipboard
vim.opt.clipboard = 'unnamedplus'

-- Virtual edit for block selection
vim.opt.virtualedit = 'block'

-- QUICKFIX LIST
vim.keymap.set("n", "<leader>oc", ":copen<CR>", { desc = "Open quickfix list" })
vim.keymap.set("n", "<leader>qc", ":cclose<CR>", { desc = "Close quickfix list" })
vim.keymap.set("n", "<leader>qn", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<leader>qp", "<cmd>cprev<CR>zz")

-- LOCATION LIST
vim.keymap.set("n", "<leader>wn", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>wp", "<cmd>lprev<CR>zz")

-- SEARCH CENTERING
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- VISUAL SELECTION
vim.keymap.set('v', '<', '<gv', { desc = 'Shift left, Keep selection' })
vim.keymap.set('v', '>', '>gv', { desc = 'Shift right, Keep selection' })

-- MOVE LINES
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- EDITING
vim.keymap.set({ "n", "v" }, "<leader>d", [[_d]], { desc = "Delete to void register" })

vim.keymap.set(
    "n",
    "<leader>s",
    [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { noremap = true, desc = "Substitute token under cursor" }
)

vim.keymap.set("n", "<leader>yy", [[:%y+<CR>]], { desc = "Yank entire file to clipboard" })
