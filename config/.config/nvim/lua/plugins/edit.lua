-- places spaces instead of tabs
vim.opt.expandtab = true

-- interpret 4 spaces as tab
vim.opt.tabstop = 4

-- shifts insert/delete 4 spaces
vim.opt.shiftwidth = 4

-- tab/backspace create/delete 4 spaces
vim.opt.softtabstop = 4

-- auto-indent new lines
vim.opt.autoindent = true

-- smart-indenting
vim.opt.smartindent = true

-- enable mouse
vim.opt.mouse = "a"
vim.o.mousescroll = "ver:1,hor:1"

-- Move selected lines up/down one line
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- delete to black hole register
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- start substituting token, for similar name
-- - case-sensitive
vim.keymap.set(
    "n",
    "<leader>s",
    [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { noremap = true, desc = "Substitute token under cursor" }
)

-- copy entire file content to clipboard
vim.keymap.set("n", "<leader>yy", [[:%y+<CR>]])

-- save file
vim.api.nvim_set_keymap('n', '<C-s>', ':update<CR>', { noremap = true, silent = true, desc = 'Save if modified' })
vim.api.nvim_set_keymap('i', '<C-s>', '<C-o>:update<CR>', { noremap = true, silent = true, desc = 'Save if modified (Insert mode)' })

return {

    "tpope/vim-sleuth", -- auto-detect tabstop & shiftwidth

    {
        "numToStr/Comment.nvim",
        opts = {},
        lazy = false,
        -- keymaps:
        -- gcc: toggle comment line
        -- gcb: toggle comment block of code
        -- gc:  toggle comment visual region
        -- gb:  toggle comment visual region as block
    },

    {
        "mbbill/undotree",

        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        end,
    },

    {
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
        opts = {},
        -- stylua: ignore
        keys = {
            { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
            { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
            { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
            { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
        },
    },

    {
        "danymat/neogen",
        config = true,
    },
}
