-- Last modified: 2026-04-10
-- No modifications necessary

-- Description: Plugin manager bootstrap (lazy.nvim) and theme loading based on kitty theme

-- Git repo: https://github.com/folke/lazy.nvim
-- Further docs: :help lazy.nvim

-- setup Lazy
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system {
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)

-- load plugins via Lazy
require("lazy").setup({
    spec = {
        { import = "plugins" },
        { import = "plugins.coding" },
        { import = "plugins.editor" },
    },
    change_detection = {
        notify = false, -- don't show notification on changes
    },
}, {})

local kitty_theme = vim.fn.system [[\
    grep '# name' ~/.config/kitty/current-theme.conf | \
    awk 'BEGIN { ORS = "" } {print $3}'
]]
if kitty_theme == "Catppuccin-Latte" then
    vim.cmd.colorscheme "catppuccin-latte"
else
    vim.cmd.colorscheme "catppuccin-mocha"
end
