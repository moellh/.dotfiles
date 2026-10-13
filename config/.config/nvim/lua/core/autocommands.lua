-- Last modified: 2026-10-13
-- No modifications necessary

-- Description: Core autocommands - yank highlight, trailing whitespace removal, autosave, autoreload

-- No external plugin - native vim configuration

-- Highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight yanked text',
    group = vim.api.nvim_create_augroup('moellh-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Remove trailing whitespaces on write without moving cursor
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    group = vim.api.nvim_create_augroup('moellh-trim', { clear = true }),
    pattern = "*",
    callback = function()
        -- Autosave also writes mid-insert and after undo: trimming there would
        -- eat the indent being typed, or add a change that drops the redo history
        local undo = vim.fn.undotree()
        if vim.fn.mode():sub(1, 1) == 'i' or undo.seq_cur ~= undo.seq_last then
            return
        end
        local view = vim.fn.winsaveview()
        vim.cmd [[%s/\s\+$//e]]
        vim.fn.winrestview(view)
    end,
})

-- Autosave: write buffers as they change, so nvim never holds unsaved edits
-- while a coding agent works on the same files, and reload what the agent
-- changed. Off by default, toggle with :AutosaveToggle / <leader>ta
vim.g.autosave = false

local autosave_group = vim.api.nvim_create_augroup('moellh-autosave', { clear = true })
local autosave_timer = assert(vim.uv.new_timer())
local autoreload_timer = assert(vim.uv.new_timer())

local function autosave(buf)
    if not vim.g.autosave or not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].autosave_paused then
        return
    end
    local bo = vim.bo[buf]
    if not bo.modified or bo.buftype ~= '' or bo.readonly or vim.api.nvim_buf_get_name(buf) == '' then
        return
    end
    -- Let FileChangedShell below catch a file that changed on disk meanwhile
    vim.cmd.checktime(buf)
    if not bo.modified or vim.b[buf].autosave_paused then
        return
    end
    vim.api.nvim_buf_call(buf, function()
        -- lockmarks: a write would otherwise move '[ and '] to the buffer ends
        local ok, err = pcall(vim.cmd, 'silent lockmarks update')
        if not ok then
            vim.b[buf].autosave_paused = true
            vim.notify('Autosave paused until the next :w, write failed: ' .. err, vim.log.levels.WARN)
        end
    end)
end

-- Normal-mode changes, leaving insert mode and leaving nvim save right away,
-- typing in insert mode saves once it pauses.
-- Scheduled: a write from inside an autocmd would not fire BufWritePre/Post
vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave', 'FocusLost' }, {
    desc = 'Autosave changed buffer',
    group = autosave_group,
    callback = function(args)
        vim.schedule(function()
            autosave(args.buf)
        end)
    end,
})

vim.api.nvim_create_autocmd({ 'TextChangedI', 'TextChangedP' }, {
    desc = 'Autosave changed buffer after a typing pause',
    group = autosave_group,
    callback = function(args)
        autosave_timer:start(1000, 0, vim.schedule_wrap(function()
            autosave(args.buf)
        end))
    end,
})

-- Never overwrite a file that changed on disk under unsaved edits: nvim would
-- ask before writing, and autosave would answer that prompt with the next key
vim.api.nvim_create_autocmd('FileChangedShell', {
    desc = 'Pause autosave on a conflict with the file on disk',
    group = autosave_group,
    callback = function(args)
        if not vim.g.autosave or vim.v.fcs_reason ~= 'conflict' then
            vim.v.fcs_choice = 'ask'
            return
        end
        vim.b[args.buf].autosave_paused = true
        vim.notify(
            vim.fn.fnamemodify(args.file, ':~:.')
                .. ' changed on disk under unsaved edits, autosave paused.\n'
                .. ':e! takes the version on disk, :w! keeps yours',
            vim.log.levels.WARN
        )
    end,
})

vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost' }, {
    desc = 'Resume autosave once buffer and file agree again',
    group = autosave_group,
    callback = function(args)
        vim.b[args.buf].autosave_paused = nil
    end,
})

vim.api.nvim_create_user_command('AutosaveToggle', function()
    vim.g.autosave = not vim.g.autosave
    if vim.g.autosave then
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            autosave(buf)
        end
        -- Poll for files changed on disk, nvim on its own only checks when
        -- it regains focus
        autoreload_timer:start(1000, 1000, vim.schedule_wrap(function()
            if vim.fn.mode() ~= 'c' and vim.fn.getcmdwintype() == '' then
                vim.cmd('silent! checktime')
            end
        end))
    else
        autoreload_timer:stop()
    end
    vim.notify('Autosave ' .. (vim.g.autosave and 'on' or 'off'))
end, { desc = 'Toggle autosave' })

vim.keymap.set('n', '<leader>ta', '<cmd>AutosaveToggle<CR>', { desc = '[T]oggle [A]utosave' })
