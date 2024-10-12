vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('moellh', {}),
    callback = function(e)
        local opts = { buffer = e.buf }

        -- goto definition of current token
        vim.keymap.set('n', 'gd', function()
            vim.lsp.buf.definition()
        end, opts)

        -- show information of current token
        vim.keymap.set('n', 'K', function()
            vim.lsp.buf.hover()
        end, opts)

        -- lists query of current workspace
        vim.keymap.set('n', '<leader>vws', function()
            vim.lsp.buf.workspace_symbol()
        end, opts)

        -- show diagnostics of current line
        vim.keymap.set('n', '<leader>vd', function()
            vim.diagnostic.open_float()
        end, opts)

        -- calls code actions of current line
        vim.keymap.set('n', '<leader>vca', function()
            vim.lsp.buf.code_action()
        end, opts)

        -- quicklists references of current token
        vim.keymap.set('n', '<leader>vrr', function()
            vim.lsp.buf.references()
        end, opts)

        -- rename current token
        vim.keymap.set('n', '<leader>vrn', function()
            vim.lsp.buf.rename()
        end, opts)

        -- displays function name, parameters and return type
        vim.keymap.set('i', '<C-h>', function()
            vim.lsp.buf.signature_help()
        end, opts)

        -- show next diagnostic
        vim.keymap.set('n', '[d', function()
            vim.diagnostic.goto_next()
        end, opts)

        -- show previous diagnostic
        vim.keymap.set('n', ']d', function()
            vim.diagnostic.goto_prev()
        end, opts)
    end,
})

return {

    'williamboman/mason-lspconfig.nvim',

    {
        'folke/neodev.nvim',
        opts = {},
    },

    {
        'neovim/nvim-lspconfig',

        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
        },

        config = function()
            require('mason').setup()
            require('mason-lspconfig').setup {
                ensure_installed = {
                    'pyright', -- python
                    'lua_ls', -- lua
                    'jdtls', -- java
                    'ts_ls', -- js, ts
                    'marksman', -- markdown
                    'texlab', -- latex
                    'ltex', -- latex
                    'bashls', -- bash
                    'clangd', -- cpp
                    'rust_analyzer', -- rust
                    'bashls', -- bash
                },
            }

            require('neodev').setup {}

            local lspconfig = require 'lspconfig'

            -- python
            lspconfig.pyright.setup {
                filetypes = { 'python' },
            }
            lspconfig.lua_ls.setup { -- lua
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = 'Replace',
                        },
                        diagnostics = {
                            -- Get the language server to recognize the `vim` global
                            globals = { 'vim' },
                        },
                    },
                },
            }
            lspconfig.jdtls.setup {} -- java
            lspconfig.ts_ls.setup {} -- js, ts
            lspconfig.marksman.setup {} -- markdown

            -- latex
            lspconfig.texlab.setup {}
            lspconfig.ltex.setup {}

            lspconfig.bashls.setup {}

            lspconfig.clangd.setup {}
        end,
    },

    'mfussenegger/nvim-jdtls',

    {
        'barreiroleo/ltex_extra.nvim',
        ft = { 'markdown', 'tex', 'bib' },
        dependencies = { 'neovim/nvim-lspconfig' },
        -- yes, you can use the opts field, just I'm showing the setup explicitly
        config = function()
            require('ltex_extra').setup {
                -- your_ltex_extra_opts,
                server_opts = {
                    -- capabilities = your_capabilities,
                    on_attach = function(client, bufnr)
                        -- your on_attach process
                    end,
                    settings = {
                        ltex = {},
                    },
                },
            }
        end,
    },
}
