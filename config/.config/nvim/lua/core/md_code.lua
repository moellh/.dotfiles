-- Last modified: 2026-11-11

-- Description: Markdown code helpers, mapped in ftplugin/markdown.lua
--   insert()  <M-v> in insert mode: type `|` with the cursor inside;
--             <Tab> jumps past the closing ` (it's a snippet, so blink/vim.snippet handle it)
--   wrap()    <M-v> in visual mode: v wraps the selection in `...`,
--             V wraps the lines in a ``` fence and starts insert to type the language

local M = {}

function M.insert()
    vim.snippet.expand("`$1`$0")
end

function M.wrap()
    local mode = vim.api.nvim_get_mode().mode
    if mode ~= "v" and mode ~= "V" then
        return vim.notify("md_code: use v or V, not block visual", vim.log.levels.WARN)
    end
    vim.cmd("normal! \27") -- leave visual mode so '< and '> are set
    local s, e = vim.api.nvim_buf_get_mark(0, "<"), vim.api.nvim_buf_get_mark(0, ">")

    if mode == "V" then
        local indent = vim.api.nvim_buf_get_lines(0, s[1] - 1, s[1], true)[1]:match("^%s*")
        vim.api.nvim_buf_set_lines(0, e[1], e[1], true, { indent .. "```" })
        vim.api.nvim_buf_set_lines(0, s[1] - 1, s[1] - 1, true, { indent .. "```" })
        vim.api.nvim_win_set_cursor(0, { s[1], 0 })
        return vim.cmd("startinsert!")
    end

    -- '> points at the first byte of the last char (or past the end after v$)
    local line = vim.api.nvim_buf_get_lines(0, e[1] - 1, e[1], true)[1]
    local col = math.min(e[2], math.max(#line - 1, 0))
    local after = col + #vim.fn.strpart(line, col, 1, true)
    vim.api.nvim_buf_set_text(0, e[1] - 1, after, e[1] - 1, after, { "`" })
    vim.api.nvim_buf_set_text(0, s[1] - 1, s[2], s[1] - 1, s[2], { "`" })
    -- cursor on the closing `, so `a` continues typing after it
    vim.api.nvim_win_set_cursor(0, { e[1], after + (s[1] == e[1] and 1 or 0) })
end

return M
