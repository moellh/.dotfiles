-- Last modified: 2026-11-23

-- Description: Jupyter notebook helpers, attached in ftplugin/markdown.lua to
--   .ipynb buffers. jupytext.nvim shows those as markdown: code cells are
--   ```python blocks, everything else is markdown cells.
--   Code runs through molten-nvim in a kernel for the nearest .venv, which
--   is registered as a Jupyter kernel on first use (system python without one).
--   otter.nvim gives the code blocks pyright.
--   Keymaps: see M.attach()

local M = {}

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = "notebook" })
end

--------------------------------------------------------------------------------
-- Cells
--------------------------------------------------------------------------------

-- Code cells as { head, first, last, stop } with 1-based rows: head is the
-- ```python line, stop the closing ```, first..last the code in between
-- (last < first when empty). Fences inside jupytext's <!-- #region -->
-- blocks are part of a markdown cell.
local function cells()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local res, open, region = {}, nil, false
    for row, line in ipairs(lines) do
        if open then
            if line:match "^```%s*$" then
                table.insert(
                    res,
                    {
                        head = open,
                        first = open + 1,
                        last = row - 1,
                        stop = row,
                    }
                )
                open = nil
            end
        elseif line:match "^<!%-%- #region" then
            region = true
        elseif line:match "^<!%-%- #endregion" then
            region = false
        elseif
            not region
            and (line:match "^```python$" or line:match "^```python%s")
        then
            open = row
        end
    end
    return res
end

local function cursor_row()
    return vim.api.nvim_win_get_cursor(0)[1]
end

-- Index of the code cell holding the cursor, nil outside of one
local function current(cs)
    local row = cursor_row()
    for i, cell in ipairs(cs) do
        if cell.head <= row and row <= cell.stop then
            return i
        end
    end
end

-- Number of code cells starting at or above the cursor
local function above(cs)
    local row, n = cursor_row(), 0
    for i, cell in ipairs(cs) do
        if cell.head <= row then
            n = i
        end
    end
    return n
end

local function jump(cell)
    if vim.api.nvim_get_mode().mode == "n" then
        vim.cmd "normal! m'"
    end
    vim.api.nvim_win_set_cursor(0, { math.min(cell.first, cell.stop), 0 })
end

-- ]c / [c to the code of the next / previous code cell; [c first goes to the
-- start of the current one, like [[
function M.goto_next()
    local cs, row = cells(), cursor_row()
    local target
    for _ = 1, vim.v.count1 do
        for _, cell in ipairs(cs) do
            if cell.head > row then
                target, row = cell, cell.head
                break
            end
        end
    end
    if target then
        jump(target)
    end
end

function M.goto_prev()
    local cs, row = cells(), cursor_row()
    local target
    for _ = 1, vim.v.count1 do
        local found
        for _, cell in ipairs(cs) do
            if math.min(cell.first, cell.stop) < row then
                found = cell
            end
        end
        if not found then
            break
        end
        target, row = found, math.min(found.first, found.stop)
    end
    if target then
        jump(target)
    end
end

-- New cell below the current code cell (or the cursor line), in insert mode.
-- Markdown cells need no marker, any text between code blocks is one
function M.new_cell(kind)
    local cs = cells()
    local cell = cs[current(cs)]
    local after = cell and cell.stop or cursor_row()
    local lines = kind == "markdown" and { "", "" }
        or { "", "```python", "", "```" }
    vim.api.nvim_buf_set_lines(0, after, after, true, lines)
    vim.api.nvim_win_set_cursor(
        0,
        { after + (kind == "markdown" and 2 or 3), 0 }
    )
    vim.cmd "startinsert"
end

-- mini.ai textobject: ic = code of the cell, ac = with its fences
function M.textobject(ai_type)
    local cs = cells()
    local cell = cs[current(cs)]
    if not cell then
        return nil
    end
    local from, to = cell.first, cell.last
    if ai_type == "a" then
        from, to = cell.head, cell.stop
    end
    if to < from then
        return nil
    end
    local last_line = vim.api.nvim_buf_get_lines(0, to - 1, to, true)[1]
    return {
        from = { line = from, col = 1 },
        to = { line = to, col = math.max(#last_line, 1) },
        vis_mode = "V",
    }
end

--------------------------------------------------------------------------------
-- Kernel
--------------------------------------------------------------------------------

-- Python, kernel name and display name for the notebook in this buffer
local function kernel_spec()
    local file = vim.api.nvim_buf_get_name(0)
    local venv = vim.fs.find(
        ".venv",
        { upward = true, type = "directory", path = vim.fs.dirname(file) }
    )[1]
    if not venv then
        return {
            python = "/usr/bin/python3",
            name = "python3-system",
            display = "Python 3 (system)",
        }
    end
    local project = vim.fs.dirname(venv)
    local slug = vim.fn
        .fnamemodify(project, ":~")
        :gsub("^~/?", "")
        :lower()
        :gsub("[^%w]+", "-")
        :gsub("^%-+", "")
    return {
        python = venv .. "/bin/python",
        name = "venv-" .. slug:gsub("%-+$", ""),
        display = "Python (" .. vim.fn.fnamemodify(project, ":~") .. ")",
    }
end

-- Register the kernel with Jupyter unless it already is. Returns success
local function register(spec)
    local data = vim.env.JUPYTER_DATA_DIR
        or (
            (vim.env.XDG_DATA_HOME or vim.fn.expand "~/.local/share")
            .. "/jupyter"
        )
    if vim.uv.fs_stat(data .. "/kernels/" .. spec.name .. "/kernel.json") then
        return true
    end
    if
        vim.system({ spec.python, "-c", "import ipykernel" }):wait().code ~= 0
    then
        notify(
            "No ipykernel in "
                .. spec.python
                .. ", install it with:\nuv pip install --python "
                .. spec.python
                .. " ipykernel",
            vim.log.levels.ERROR
        )
        return false
    end
    local cmd = {
        spec.python,
        "-m",
        "ipykernel",
        "install",
        "--user",
        "--name",
        spec.name,
        "--display-name",
        spec.display,
    }
    local res = vim.system(cmd, { text = true }):wait()
    if res.code ~= 0 then
        notify(
            "Registering kernel " .. spec.name .. " failed:\n" .. res.stderr,
            vim.log.levels.ERROR
        )
        return false
    end
    notify("Registered Jupyter kernel " .. spec.name)
    return true
end

-- Id of the kernel attached to this buffer, nil without one
local function kernel_id()
    local ok, kernels = pcall(vim.fn.MoltenRunningKernels, true)
    return ok and kernels[1] or nil
end

-- molten keeps code sent to a still starting kernel "On Hold" for good, so
-- runs wait in a queue for its MoltenKernelReady event
local starting = {} -- kernel id -> queued { buf, fn }

vim.api.nvim_create_autocmd("User", {
    pattern = "MoltenKernelReady",
    group = vim.api.nvim_create_augroup("moellh-notebook", { clear = true }),
    callback = function(args)
        local id = args.data and args.data.kernel_id
        local queue = id and starting[id]
        if not queue then
            return
        end
        starting[id] = nil
        -- scheduled: this runs inside molten's tick, which can't take new code
        vim.schedule(function()
            for _, job in ipairs(queue) do
                if vim.api.nvim_buf_is_valid(job.buf) then
                    vim.api.nvim_buf_call(job.buf, job.fn)
                end
            end
        end)
    end,
})

-- Start the kernel for this notebook and show the outputs saved in it.
-- Returns the kernel id
function M.init_kernel()
    if kernel_id() then
        return notify "Kernel already running, restart with <leader>jR"
    end
    local spec = kernel_spec()
    if not register(spec) then
        return
    end
    local ok, err = pcall(vim.cmd.MoltenInit, spec.name)
    local id = kernel_id()
    if not ok or not id then
        return notify(
            "MoltenInit failed (try :UpdateRemotePlugins):\n" .. tostring(err),
            vim.log.levels.ERROR
        )
    end
    starting[id] = starting[id] or {}
    pcall(vim.cmd.MoltenImportOutput)
    return id
end

-- Call fn now if the kernel is ready, else once it is, starting it if needed
local function with_kernel(fn)
    local id = kernel_id() or M.init_kernel()
    if not id then
        return
    end
    if starting[id] then
        table.insert(
            starting[id],
            { buf = vim.api.nvim_get_current_buf(), fn = fn }
        )
        return notify "Kernel starting, runs once it is ready"
    end
    fn()
end

--------------------------------------------------------------------------------
-- Running
--------------------------------------------------------------------------------

local function eval_cells(list)
    -- ranges now, the buffer may change until the kernel is ready
    local ranges = {}
    for _, cell in ipairs(list) do
        if cell.last >= cell.first then
            table.insert(ranges, { cell.first, cell.last })
        end
    end
    if #ranges == 0 then
        return
    end
    with_kernel(function()
        for _, r in ipairs(ranges) do
            vim.fn.MoltenEvaluateRange(r[1], r[2])
        end
    end)
end

function M.run_cell()
    local cs = cells()
    local cell = cs[current(cs)]
    if not cell then
        return notify("Not in a code cell", vim.log.levels.WARN)
    end
    eval_cells { cell }
end

-- Run the cell and jump to the next code cell, like Shift-Enter in Jupyter
function M.run_cell_and_next()
    local cs = cells()
    local cell = cs[current(cs)]
    if cell then
        eval_cells { cell }
    end
    M.goto_next()
end

function M.run_above()
    local cs = cells()
    eval_cells(vim.list_slice(cs, 1, above(cs)))
end

function M.run_all()
    eval_cells(cells())
end

function M.run_line()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    with_kernel(function()
        vim.fn.MoltenEvaluateRange(row, row)
    end)
end

function M.run_selection()
    vim.cmd "normal! \27" -- leave visual mode so '< and '> are set
    with_kernel(function()
        vim.cmd.MoltenEvaluateVisual()
    end)
end

-- Fresh kernel without outputs; runs wait until it is ready again
function M.restart()
    local id = kernel_id()
    if not id then
        return notify("No kernel running", vim.log.levels.WARN)
    end
    vim.cmd "MoltenRestart!"
    starting[id] = starting[id] or {}
end

--------------------------------------------------------------------------------
-- Saving outputs into the .ipynb
--------------------------------------------------------------------------------

-- jupytext.nvim converts in the background by default, these need the
-- notebook on disk to match the buffer first
local function write_now()
    vim.b.jupytext_async_write = false
    local ok, err = pcall(vim.cmd.write)
    vim.b.jupytext_async_write = nil
    if not ok then
        notify(err, vim.log.levels.ERROR)
    end
    return ok
end

-- jupytext.nvim asks before overwriting a notebook that changed on disk since
-- it was read; outputs written by us should not count as such a change
local function adopt_disk_version(buf, file)
    local stat = vim.uv.fs_stat(file)
    if stat and vim.api.nvim_buf_is_valid(buf) then
        vim.b[buf].mtime = stat.mtime
    end
end

-- Write the outputs molten shows into the notebook file
function M.export()
    if not kernel_id() then
        return notify(
            "No kernel running, nothing to export",
            vim.log.levels.WARN
        )
    end
    if not write_now() then
        return
    end
    local ok, err = pcall(vim.cmd, "MoltenExportOutput!")
    if not ok then
        return notify("Export failed:\n" .. err, vim.log.levels.ERROR)
    end
    adopt_disk_version(
        vim.api.nvim_get_current_buf(),
        vim.api.nvim_buf_get_name(0)
    )
end

-- Run the whole notebook top to bottom in a fresh kernel with nbconvert and
-- store all outputs in the file, e.g. for a submission. Stops at the first
-- error without touching the file.
function M.execute()
    local buf = vim.api.nvim_get_current_buf()
    local file = vim.api.nvim_buf_get_name(buf)
    if not write_now() then
        return
    end
    local spec = kernel_spec()
    local cmd
    if
        vim.system({ spec.python, "-c", "import nbconvert" }):wait().code == 0
    then
        -- The notebook's python3 kernel then resolves to this python
        cmd = { spec.python, "-m", "nbconvert" }
    elseif register(spec) then
        cmd = {
            "jupyter",
            "nbconvert",
            "--ExecutePreprocessor.kernel_name=" .. spec.name,
        }
    else
        return
    end
    vim.list_extend(cmd, { "--to", "notebook", "--execute", "--inplace", file })

    local name = vim.fn.fnamemodify(file, ":t")
    notify("Executing " .. name .. " with " .. spec.display .. " ...")
    vim.system(
        cmd,
        { cwd = vim.fs.dirname(file), text = true },
        vim.schedule_wrap(function(res)
            if res.code ~= 0 then
                local lines = vim.split(vim.trim(res.stderr), "\n")
                local tail = table.concat(
                    vim.list_slice(lines, math.max(#lines - 15, 1)),
                    "\n"
                )
                return notify(
                    "Executing " .. name .. " failed, file unchanged:\n" .. tail,
                    vim.log.levels.ERROR
                )
            end
            adopt_disk_version(buf, file)
            notify("Executed " .. name .. ", outputs saved")
        end)
    )
end

--------------------------------------------------------------------------------
-- Keymaps
--------------------------------------------------------------------------------

function M.attach(buf)
    local function map(modes, lhs, rhs, desc)
        vim.keymap.set(
            modes,
            lhs,
            rhs,
            { buffer = buf, silent = true, desc = "Jupyter: " .. desc }
        )
    end
    local function cmd(command)
        return function()
            vim.cmd(command)
        end
    end

    map("n", "<leader>ji", M.init_kernel, "[I]nit kernel")
    map("n", "<leader>jr", M.run_cell, "[R]un cell")
    map("x", "<leader>jr", M.run_selection, "[R]un selection")
    map("n", "<leader>jj", M.run_cell_and_next, "Run cell, next cell")
    map("n", "<leader>ja", M.run_above, "Run cells [A]bove (incl. current)")
    map("n", "<leader>jA", M.run_all, "Run [A]ll cells")
    map("n", "<leader>jl", M.run_line, "Run [L]ine")
    map(
        "n",
        "<leader>jo",
        cmd "noautocmd MoltenEnterOutput",
        "Enter [O]utput window"
    )
    map("n", "<leader>jh", cmd "MoltenHideOutput", "[H]ide output window")
    map("n", "<leader>jd", cmd "MoltenDelete", "[D]elete cell output")
    map(
        "n",
        "<leader>jy",
        cmd "MoltenYankOutput!",
        "[Y]ank output to clipboard"
    )
    map("n", "<leader>jp", cmd "MoltenImagePopup", "Image [P]opup in viewer")
    map("n", "<leader>jc", cmd "MoltenInterrupt", "Interrupt kernel ([C]trl-C)")
    map("n", "<leader>jR", M.restart, "[R]estart kernel, clear outputs")
    map("n", "<leader>jb", function()
        M.new_cell "code"
    end, "New code cell [B]elow")
    map("n", "<leader>jm", function()
        M.new_cell "markdown"
    end, "New [M]arkdown cell below")
    map("n", "<leader>je", M.export, "[E]xport outputs into .ipynb")
    map("n", "<leader>jx", M.execute, "E[x]ecute notebook, save outputs")
    map({ "n", "x", "o" }, "]c", M.goto_next, "Next cell")
    map({ "n", "x", "o" }, "[c", M.goto_prev, "Previous cell")

    -- ic / ac cell textobjects (vic, yac, dac, ...)
    vim.b[buf].miniai_config = { custom_textobjects = { c = M.textobject } }

    -- pyright etc. in the code blocks
    require("otter").activate { "python" }
end

return M
