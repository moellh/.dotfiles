vim.opt.wrap = true

-- .ipynb notebooks shown as py:percent text by jupytext.nvim, see lua/core/notebook.lua
if vim.api.nvim_buf_get_name(0):match "%.ipynb$" then
    require("core.notebook").attach(0)
end
