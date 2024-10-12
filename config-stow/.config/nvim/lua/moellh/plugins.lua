-- setup Lazy
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable',
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)

-- load plugins via Lazy
require('lazy').setup({
    spec = 'moellh.custom', -- plugins are in custom/ directory
    change_detection = {
        notify = false, -- don't show notification on changes
    },
}, {})
