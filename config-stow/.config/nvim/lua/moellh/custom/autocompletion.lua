return {

    { -- autocompletion
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter', -- just before insert mode (or similar)

        dependencies = {
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip', -- luasnip for cmp
            'hrsh7th/cmp-nvim-lsp', -- nvim-lsp for cmp
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-path', -- path for cmp
            'rafamadriz/friendly-snippets', -- pre-configured snippets
        },

        config = function()
            -- See `:help cmp`
            local cmp = require 'cmp'
            local luasnip = require 'luasnip'

            local cmp_lsp = require 'cmp_nvim_lsp'
            local capabilities = vim.tbl_deep_extend(
                'force',
                {},
                vim.lsp.protocol.make_client_capabilities(),
                cmp_lsp.default_capabilities()
            )

            luasnip.config.setup {}

            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },

                completion = {
                    completeopt = 'menu,menuone,noinsert',
                },

                -- TODO: read `:help ins-completion` for choice of mappings

                mapping = cmp.mapping.preset.insert {

                    -- select [n]ext item
                    ['<C-n>'] = cmp.mapping.select_next_item(),

                    -- select [p]revious item
                    ['<C-p>'] = cmp.mapping.select_prev_item(),

                    -- accept ([y]es) completion
                    -- expands snippet, auto-imports from lsp
                    ['<C-y>'] = cmp.mapping.confirm { select = true },

                    -- manually trigger completion from nvim-cmp
                    ['<C-Space>'] = cmp.mapping.complete {},

                    -- jump to next placeholder
                    ['<C-l>'] = cmp.mapping(function()
                        if luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        end
                    end, { 'i', 's' }), -- in insert or select mode

                    -- jump to previous placeholder
                    ['<C-h>'] = cmp.mapping(function()
                        if luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        end
                    end, { 'i', 's' }),
                },

                -- source cmp with lsp, snippets, path
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'buffer' },
                    { name = 'path' },
                },
            }
        end,
    },
}
