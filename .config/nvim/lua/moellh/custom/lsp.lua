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
                    'tsserver', -- js, ts
                    'marksman', -- markdown
                    'texlab', -- latex
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
                        --[[ diagnostics = {
                            -- Get the language server to recognize the `vim` global
                            globals = { 'vim' },
                        },
                        workspace = {
                            -- Make the server aware of Neovim runtime files and plugins
                            library = { vim.env.VIMRUNTIME },
                            checkThirdParty = false,
                        },
                        telemetry = {
                            enable = false,
                        }, ]]
                    },
                },
            }
            lspconfig.jdtls.setup {} -- java
            lspconfig.tsserver.setup {} -- js, ts
            lspconfig.marksman.setup {} -- markdown

            -- latex
            lspconfig.texlab.setup {}

            lspconfig.bashls.setup {}
        end,
    },

    'mfussenegger/nvim-jdtls',
}
