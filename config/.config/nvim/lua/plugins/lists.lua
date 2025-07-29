-- QUICKFIX LIST

-- open & close close quickfix list
vim.keymap.set("n", "<leader>oc", ":copen<CR>", { desc = "Open quickfix list" })
vim.keymap.set("n", "<leader>qc", ":cclose<CR>", { desc = "Close quickfix list" })

-- navigate quickfix list
vim.keymap.set("n", "<leader>qn", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<leader>qp", "<cmd>cprev<CR>zz")

-- LOCATION LIST

-- navigate location list
vim.keymap.set("n", "<leader>wn", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>wp", "<cmd>lprev<CR>zz")

return {}
