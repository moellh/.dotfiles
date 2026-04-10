-- Last modified: 2026-04-10
-- Coding-related plugins: treesitter, formatting, debugging, snippets

-- Treesitter: syntax highlighting, indentation, text objects
-- nvim-treesitter: https://github.com/nvim-treesitter/nvim-treesitter
-- nvim-treesitter-textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects

-- Formatting: conform.nvim
-- conform.nvim: https://github.com/stevearc/conform.nvim

-- Debugging: nvim-dap
-- nvim-dap: https://github.com/mfussenegger/nvim-dap
-- nvim-dap-ui: https://github.com/rcarriga/nvim-dap-ui
-- mason-nvim-dap: https://github.com/jay-babu/mason-nvim-dap.nvim
-- nvim-dap-python: https://github.com/mfussenegger/nvim-dap-python

-- =============================================================================
-- Remove trailing whitespaces on write
-- =============================================================================
local moellh_group = vim.api.nvim_create_augroup("moellh", { clear = false })
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    group = moellh_group,
    pattern = "*",
    callback = function()
        local view = vim.fn.winsaveview()
        vim.cmd [[%s/\s\+$//e]]
        vim.fn.winrestview(view)
    end
})

return {

    -- =============================================================================
    -- TREESITTER
    -- =============================================================================
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            -- Install all parsers
            require("nvim-treesitter").install "unstable"

            -- Enable highlighting
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "*",
                callback = function()
                    local buf = vim.api.nvim_get_current_buf()
                    local ft = vim.bo[buf].filetype
                    local filename = vim.api.nvim_buf_get_name(buf)

                    local mappings = {
                        ["hypr*.conf"] = "hyprlang",
                    }

                    for pattern, lang in pairs(mappings) do
                        if string.match(filename, pattern) then
                            vim.treesitter.start(buf, lang)
                            return
                        end
                    end

                    if
                        vim.tbl_contains(
                            require("nvim-treesitter").get_installed "parsers",
                            ft
                        )
                    then
                        vim.treesitter.start(buf)
                        return
                    end

                    -- Else ignore
                end,
            })

            -- Enable treesitter-based indentation globally
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "*",
                callback = function()
                    local buf = vim.api.nvim_get_current_buf()
                    vim.bo[buf].indentexpr =
                        "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        init = function()
            -- Disable entire built-in ftplugin mappings to avoid conflicts.
            vim.g.no_plugin_maps = true
        end,
        config = function()
            -- put your config here
        end,
    },

    -- =============================================================================
    -- FORMATTING
    -- =============================================================================
    {
        "stevearc/conform.nvim",
        opts = {
            notify_on_error = false,
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "isort", "black" },
                javascript = { "prettierd" },
                java = { "google-java-format" },
                c = { "clang-format" },
                glsl = { "clang-format" },
                cpp = { "clang-format" },
                cuda = { "clang-format" },
                bash = { "shfmt" },
                bib = { "bibtex-tidy" },
                rust = { "rustfmt" },
            },
            formatters = {
                black = {
                    prepend_args = { "--line-length", "120" },
                },
                ["bibtex-tidy"] = {
                    args = {
                        "--curly",
                        "--wrap=120",
                        "--space=4",
                        "--blank-lines",
                    },
                },
            },
        },
        keys = {
            {
                "<leader>f",
                function()
                    require("conform").format { async = true }
                end,
                mode = "",
                desc = "Format buffer",
            },
        },
    },

    -- =============================================================================
    -- DEBUGGING
    -- =============================================================================
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'rcarriga/nvim-dap-ui',
            'williamboman/mason.nvim',
            'jay-babu/mason-nvim-dap.nvim',
            'mfussenegger/nvim-dap-python',
        },
        config = function()
            local dap = require 'dap'
            local dapui = require 'dapui'

            require('mason-nvim-dap').setup {
                automatic_setup = false,
                automatic_installation = false,
                handlers = {},
                ensure_installed = {},
            }

            vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
            vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
            vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
            vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
            vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
            vim.keymap.set('n', '<leader>B', function()
                dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
            end, { desc = 'Debug: Set Breakpoint' })

            dapui.setup {
                icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
                controls = {
                    icons = {
                        pause = '⏸',
                        play = '▶',
                        step_into = '⏎',
                        step_over = '⏭',
                        step_out = '⏮',
                        step_back = 'b',
                        run_last = '▶▶',
                        terminate = '⏹',
                        disconnect = '⏏',
                    },
                },
            }

            vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

            dap.listeners.after.event_initialized['dapui_config'] = dapui.open
            dap.listeners.before.event_terminated['dapui_config'] = dapui.close
            dap.listeners.before.event_exited['dapui_config'] = dapui.close

            require('dap-python').setup()

            dap.configurations.cpp = {
                {
                    name = 'Launch file',
                    type = 'codelldb',
                    request = 'launch',
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                },
            }

            dap.configurations.c = dap.configurations.cpp
            dap.configurations.rust = dap.configurations.cpp
        end,
    },

    -- =============================================================================
    -- SNIPPETS (builtin via blink.cmp)
    -- =============================================================================
    -- blink.cmp handles snippets natively with preset = "default"
    -- No luasnip required - using blink's builtin snippet support
}
