-- Last modified: 2026-04-10
-- =============================================================================
-- LSP Configuration (Neovim 0.11+)
-- =============================================================================
-- Merged from: lsp.lua, mason.lua, mason-lspconfig.lua, diagnostics.lua
--
-- LSP servers configured in ~/.config/nvim/lsp/*.lua (auto-discovered by Neovim 0.11+)
--
-- Manual LSP installation on Arch:
--   pacman -S pyright lua-language-server typescript-language-server
--   pacman -S marksman texlab ltex-ls-plus bash-language-server clangd
--   pacman -S rust-analyzer cmake-language-server html-languageserver zls tinymist
--   yay -S glsl_analyzer jdtls
--
-- Java LSP (jdtls) is configured in ftplugin/java.lua
-- Requires java-runtime (>=17), java (26) already installed
--
-- To enable Mason LSP installation:
--   NVIM_ENABLE_MASON_LSP=1 nvim
-- =============================================================================

-- Log level: WARN includes both warnings and errors
vim.lsp.log.set_level(vim.log.levels.WARN)

-- Auto-trim LSP log file on startup (remove entries older than 1 day)
vim.defer_fn(function()
    local log_file = vim.fn.stdpath "state" .. "/lsp.log"
    local ok, lines = pcall(vim.fn.readfile, log_file)
    if not ok then
        return
    end

    local cutoff = os.time() - 86400 -- 1 day in seconds
    local new_lines = {}
    local keep = true

    for _, line in ipairs(lines) do
        local year, month, day, hour, min, sec = line:match "%[(%d%d%d%d)%-(%d%d)%-(%d%d) (%d%d):(%d%d):(%d%d)%]"
        if year then
            local entry_time = os.time {
                year = tonumber(year),
                month = tonumber(month),
                day = tonumber(day),
                hour = tonumber(hour),
                min = tonumber(min),
                sec = tonumber(sec),
            }
            keep = entry_time and entry_time >= cutoff
        end
        if keep or line:match "^%[START%]" then
            table.insert(new_lines, line)
        end
    end

    if #new_lines < #lines then
        vim.fn.writefile(new_lines, log_file)
    end
end, 100)

-- LspAttach keymaps (blink.cmp handles completion, no vim.lsp.completion.enable())
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local opts = { buffer = args.buf }

        vim.keymap.set("n", "grt", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "grd", vim.lsp.buf.declaration, opts)
        -- Note: completion handled by blink.cmp, not vim.lsp.completion
    end,
})

-- Diagnostics configuration
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('moellh', {}),
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set('n', '<leader>ll', function()
            vim.diagnostic.open_float()
        end, {
            buffer = e.buf,
            desc = "Show diagnostics of current line",
        })
    end
})

vim.diagnostic.config {
    float = {
        focusable = false,
        style = 'minimal',
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
    },
}

-- Enable LSP servers (Neovim 0.11+ lsp/*.lua configs)
local servers = {
    "lua_ls",
    "pyright",
    "clangd",
    "rust_analyzer",
    "ts_ls",
    "bashls",
    "marksman",
    "texlab",
    "ltex",
    "cmake",
    "html",
    "zls",
    "tinymist",
    "glsl_analyzer",
}

for _, server in ipairs(servers) do
    vim.lsp.enable(server)
end

-- Mason LSP condition
local enable_mason_lsp = vim.env.NVIM_ENABLE_MASON_LSP == "1"

return {

    -- Required by lazydev.nvim
    {
        "Bilal2453/luvit-meta",
        lazy = true,
    },

    -- Java LSP (JDTLS)
    "mfussenegger/nvim-jdtls",

    -- LTeX extra for code actions
    {
        "barreiroleo/ltex_extra.nvim",
        enabled = true,
        ft = { "markdown", "tex", "bib", "text", "gitcommit", "rst", "org" },
    },

    -- Mason (lazy, required by mason-nvim-dap)
    {
        'williamboman/mason.nvim',
        lazy = true,
        config = function()
            require("mason").setup()
        end,
    },

    -- Mason LSP config (conditionally enabled)
    {
        'williamboman/mason-lspconfig.nvim',
        enabled = enable_mason_lsp,
        dependencies = { 'williamboman/mason.nvim' },
        config = function()
            require("mason-lspconfig").setup {
                automatic_installation = false,
            }
        end,
    },
}
