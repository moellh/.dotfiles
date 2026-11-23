vim.opt.wrap = true
vim.opt.conceallevel = 0

-- Wrapped lines of list items start below the item's text, not at the left
-- edge: breakindent (on globally) shifted by the match of formatlistpat,
-- which after/ftplugin/markdown.lua extends
vim.opt_local.breakindentopt = "list:-1"

-- Markdown links, see lua/core/md_link.lua
local md_link = require("core.md_link")
local function map(modes, lhs, fn, desc, expr)
    vim.keymap.set(modes, lhs, fn, { buffer = true, desc = desc, expr = expr })
end
map("n", "gf", md_link.follow, "Follow markdown link (under cursor or next)")
map("n", "<Tab>", md_link.tab, "Continue typing after markdown link", true)
map({ "i", "x" }, "<C-]>", md_link.insert, "Insert link to file")
map({ "n", "x" }, "<leader>ml", md_link.insert, "Insert link to file")

-- Inline code and code blocks, see lua/core/md_code.lua
local md_code = require("core.md_code")
map("i", "<M-v>", md_code.insert, "Insert `code` (<Tab> jumps out)")
map("x", "<M-v>", md_code.wrap, "Wrap selection in `code` (V: ``` block)")

-- .ipynb notebooks shown as markdown by jupytext.nvim, see lua/core/notebook.lua
if vim.api.nvim_buf_get_name(0):match("%.ipynb$") then
    require("core.notebook").attach(0)
end
