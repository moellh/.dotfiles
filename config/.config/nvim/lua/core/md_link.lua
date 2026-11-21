-- Last modified: 2026-11-11

-- Description: Markdown link helpers, mapped in ftplugin/markdown.lua
--   follow()  gf: open the link under the cursor, or the next one to the right
--   tab()     <Tab>: on a link, continue typing right after its ")"
--   insert()  pick a file with Telescope and insert [name](path) to it.
--             Typing "../" at the start of the search moves the search root up.

local M = {}

-- [text](target) -> captures: first col, target, col after ")" (1-based bytes)
local LINK = "()%[[^%]]*%]%(([^)]*)%)()"

-- Link containing col (or, with ahead = true, the next one right of it)
local function find_link(col, ahead)
    for first, target, after in vim.api.nvim_get_current_line():gmatch(LINK) do
        if after > col and (ahead or first <= col) then
            return { target = target, last = after - 1 }
        end
    end
end

function M.follow()
    local link = find_link(vim.fn.col("."), true)
    if not link then
        return vim.cmd("normal! gf") -- no link on this line: plain gf
    end
    local target = link.target:gsub("^<(.*)>$", "%1"):gsub("#.*$", "")
    if target == "" then
        return -- link to a heading in this file
    elseif target:match("^%a+://") then
        return vim.ui.open(target)
    end
    vim.cmd.edit(vim.fn.fnameescape(vim.fn.expand("%:p:h") .. "/" .. target))
end

-- expr mapping: on a link, put the cursor on ")" and append; else normal <Tab>
function M.tab()
    local link = find_link(vim.fn.col("."), false)
    if not link then
        return "<Tab>"
    end
    return ("<Cmd>call cursor(0, %d)<CR>a"):format(link.last)
end

-- Path of `to` relative to the directory `from`, using ".." where needed
local function relpath(from, to)
    local a = vim.split(from, "/", { trimempty = true })
    local b = vim.split(to, "/", { trimempty = true })
    local i = 1
    while a[i] and a[i] == b[i] do
        i = i + 1
    end
    local parts = {}
    for _ = i, #a do
        table.insert(parts, "..")
    end
    for j = i, #b do
        table.insert(parts, b[j])
    end
    return table.concat(parts, "/")
end

local function realpath(path)
    return vim.uv.fs_realpath(path) or vim.fs.normalize(path)
end

-- Go up n directories from dir, but never above ~ (or /)
local function climb(dir, n)
    local home, up = vim.uv.os_homedir(), 0
    while up < n and dir ~= home and dir ~= "/" do
        dir, up = vim.fs.dirname(dir), up + 1
    end
    return dir, up
end

-- Fuzzy-pick a file under the cwd; calls on_done(abs_path), or on_done(nil) if cancelled
local function pick_file(on_done)
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    local cwd = realpath(vim.fn.getcwd()) -- respects :lcd / :tcd
    local root = cwd
    local picker

    local function finder_for(dir, up)
        local prefix = ("../"):rep(up)
        return finders.new_oneshot_job({ "fd", "--type", "f", "--color", "never" }, {
            cwd = dir,
            entry_maker = function(rel)
                local abs = dir .. "/" .. rel
                return { value = abs, path = abs, ordinal = rel, display = prefix .. rel }
            end,
        })
    end

    local function close(bufnr, result)
        actions.close(bufnr)
        vim.schedule(function()
            on_done(result)
        end)
    end

    picker = pickers.new({}, {
        prompt_title = "Link to file (../ goes up)",
        results_title = vim.fn.fnamemodify(cwd, ":~"),
        finder = finder_for(cwd, 0),
        sorter = conf.file_sorter({}),
        previewer = conf.file_previewer({}),
        on_input_filter_cb = function(prompt)
            local n = 0
            while prompt:sub(1, 3) == "../" do
                prompt, n = prompt:sub(4), n + 1
            end
            local dir, up = climb(cwd, n)
            if dir == root then
                return { prompt = prompt }
            end
            root = dir
            pcall(function()
                picker.layout.results.border:change_title(vim.fn.fnamemodify(dir, ":~"))
            end)
            return { prompt = prompt, updated_finder = finder_for(dir, up) }
        end,
        attach_mappings = function(bufnr, map)
            actions.select_default:replace(function()
                local entry = action_state.get_selected_entry()
                close(bufnr, entry and entry.value)
            end)
            local cancel = function()
                close(bufnr, nil)
            end
            map("i", "<C-c>", cancel)
            map("n", "<Esc>", cancel)
            map("n", "q", cancel)
            return true
        end,
    })
    picker:find()
end

-- Leave insert mode, then run fn (leaving insert moves the cursor, so wait for it)
local function in_normal_mode(fn)
    if vim.api.nvim_get_mode().mode:sub(1, 1) == "i" then
        vim.cmd.stopinsert()
        vim.schedule(fn)
    else
        fn()
    end
end

-- <C-]> / <leader>ml: insert mode inserts at the cursor, normal mode after it
-- (like `a`), visual mode turns the selection into the link text.
function M.insert()
    local mode = vim.api.nvim_get_mode().mode
    local buf, win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
    local cursor = vim.api.nvim_win_get_cursor(win)
    local row, line = cursor[1], vim.api.nvim_get_current_line()
    local first, last, text -- 0-based byte range to replace, and link text

    if mode == "v" or mode == "V" then
        vim.cmd("normal! \27") -- leave visual mode so '< and '> are set
        local s, e = vim.api.nvim_buf_get_mark(buf, "<"), vim.api.nvim_buf_get_mark(buf, ">")
        if s[1] ~= e[1] then
            return vim.notify("md_link: select text within one line", vim.log.levels.WARN)
        end
        row = s[1]
        line = vim.api.nvim_buf_get_lines(buf, row - 1, row, true)[1]
        if mode == "V" then
            first, last = 0, #line
        else
            local e_col = math.min(e[2], math.max(#line - 1, 0))
            first, last = s[2], e_col + #vim.fn.strpart(line, e_col, 1, true)
        end
        text = line:sub(first + 1, last)
    elseif mode == "i" then
        first = cursor[2]
    elseif mode:sub(1, 1) == "n" then
        first = #line == 0 and 0 or cursor[2] + #vim.fn.strpart(line, cursor[2], 1, true)
    else
        return
    end
    last = last or first

    pick_file(function(abs)
        if not vim.api.nvim_win_is_valid(win) then
            return
        end
        vim.api.nvim_set_current_win(win)

        if not abs then -- cancelled: go back to where we were
            return in_normal_mode(function()
                if mode == "i" then
                    vim.api.nvim_win_set_cursor(win, cursor)
                    vim.cmd(cursor[2] >= #vim.api.nvim_get_current_line() and "startinsert!" or "startinsert")
                elseif mode == "v" or mode == "V" then
                    vim.cmd("normal! gv")
                else
                    vim.api.nvim_win_set_cursor(win, cursor)
                end
            end)
        end

        local file = vim.api.nvim_buf_get_name(buf)
        local base = file == "" and vim.fn.getcwd() or vim.fs.dirname(file)
        local target = relpath(realpath(base), realpath(abs))
        if target:find("[%s()]") then
            target = "<" .. target .. ">"
        end
        if not text then
            text = vim.fn.fnamemodify(abs, ":t:r")
            text = text ~= "" and text or vim.fs.basename(abs)
        end

        vim.api.nvim_buf_set_text(buf, row - 1, first, row - 1, last, { ("[%s](%s)"):format(text, target) })
        in_normal_mode(function()
            vim.api.nvim_win_set_cursor(win, { row, first + 1 }) -- first char inside []
        end)
    end)
end

return M
