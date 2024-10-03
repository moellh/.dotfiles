--[[
-- Text Editing
--]]

vim.opt.wrap = false -- not text-wrapping
vim.opt.breakindent = true -- keep indenting, if wrapping is enabled

vim.opt.expandtab = true -- places spaces instead of tabs
vim.opt.tabstop = 4 -- interprets 4 spaces as a tab
vim.opt.shiftwidth = 4 -- shifts result in 4 spaces
vim.opt.softtabstop = 4 -- tab creates / backspace deletes 4 spaces

vim.opt.autoindent = true -- auto-indent new lines
vim.opt.smartindent = true -- smart-indenting

vim.opt.scrolloff = 8 -- cursor stays close to mid of screen when possible

vim.opt.mouse = 'a' -- enable mouse

vim.opt.undofile = true -- safe undo history to file
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

--[[
-- Yanking, Pasting, Registers
--]]

-- clipboard uses xclip
vim.opt.clipboard = 'unnamedplus' -- y,p use "+ register by default

--[[
-- Visual Mode
--]]

vim.opt.virtualedit = 'block' -- Visual Block mode treats out-of-file cells as spaces

--[[
-- Windows, Panes
--]]

vim.opt.splitbelow = true -- vertical split to bottom
vim.opt.splitright = true -- horizontal split to right

vim.opt.number = true -- show current line number
vim.opt.relativenumber = true -- show relative line numbers for upper/lower lines
vim.opt.signcolumn = 'yes' -- always show sign column

vim.opt.showmode = false -- status line without mode (use plugin instead)

vim.opt.termguicolors = true -- 24 bit UI colors
vim.g.have_nerd_font = true -- variable to enable nerd-font features

vim.opt.guicursor = '' -- shows block in insert-mode as cursor

vim.opt.colorcolumn = '81,121' -- highlights column 81 & 121
vim.opt.cursorline = true -- highlights line of cursor

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

--[[
-- Search, Replace
--]]

vim.opt.ignorecase = true -- ignores casing
vim.opt.smartcase = true -- except if capital letter exists

vim.opt.inccommand = 'split' -- :%s shows lines in split window

vim.opt.hlsearch = true -- highlight search results
