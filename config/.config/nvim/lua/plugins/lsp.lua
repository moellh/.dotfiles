-- else ~/.local/state/nvim/lsp.log will grow to huge size
-- vim.lsp.set_log_level "off"

-- NOTE: uncomment one day
-- vim.lsp.enable "luals"

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local opts = { buffer = args.buf } -- apply to buffer

        vim.keymap.set("n", "grt", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "grd", vim.lsp.buf.declaration, opts)

        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client:supports_method "textDocument/completion" then
            vim.lsp.completion.enable(true, client.id, args.buf)
        end
    end,
})

return {

    {
        -- required by lazydev.nvim
        "Bilal2453/luvit-meta",
        lazy = true,
    },

    {
        "neovim/nvim-lspconfig",

        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "nvim-lua/lsp-status.nvim",
        },

        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup {
                -- automatically install servers used in nvim-lspconfig
                automatic_installation = { exclude = { "zls" } },
                automatic_enable = false,
                -- automatically install
                ensure_installed = {
                    "bashls", -- Bash
                    "clangd", -- CPP
                    "cmake", -- CMake
                    "jdtls", -- Java
                    "lua_ls", -- Lua
                    "ltex", -- spell checker
                    "marksman", -- Markdown
                    "nil_ls", -- Nix
                    "pyright", -- Python
                    "rust_analyzer", -- Rust
                    "texlab", -- Latex
                    "tinymist", -- Typst
                    "ts_ls", -- Javascript, Typescript
                },
            }
            local lspconfig = require "lspconfig"
            local navic = require "nvim-navic"

            lspconfig.pyright.setup { -- python
                filetypes = { "python" },
                on_attach = function(client, bufnr)
                    navic.attach(client, bufnr)
                end,
            }

            lspconfig.lua_ls.setup { -- lua
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = "Replace",
                        },
                        diagnostics = {
                            -- Get the language server to recognize the `vim` global
                            globals = { "vim" },
                        },
                    },
                },
                on_attach = function(client, bufnr)
                    navic.attach(client, bufnr)
                end,
            }
            lspconfig.ts_ls.setup {
                on_attach = function(client, bufnr)
                    navic.attach(client, bufnr)
                end,
            } -- js, ts
            lspconfig.marksman.setup {
                on_attach = function(client, bufnr)
                    navic.attach(client, bufnr)
                end,
            } -- markdown

            -- latex
            lspconfig.texlab.setup {
                root_dir = lspconfig.util.root_pattern(
                    ".latexmkrc",
                    ".texlabroot",
                    "texlabroot",
                    "Tectonic.toml",
                    "Makefile",
                    ".git"
                ),
            }

            lspconfig.ltex.setup {}

            lspconfig.bashls.setup {
                on_attach = function(client, bufnr)
                    navic.attach(client, bufnr)
                end,
            }

            lspconfig.clangd.setup {
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--log=verbose",
                    "--limit-results=0",
                    "--suggest-missing-includes",
                    "--function-arg-placeholders",
                    "--all-scopes-completion",
                    "--completion-style=bundled",
                },
                init_options = {
                    fallbackFlags = { "-std=c++17" },
                    clangdFileStatus = true,
                },
                root_dir = lspconfig.util.root_pattern(
                    "compile_commands.json",
                    ".clangd",
                    ".clang-format",
                    ".git"
                ),
                on_attach = function(client, bufnr)
                    navic.attach(client, bufnr)
                end,
            }

            lspconfig.rust_analyzer.setup {}

            lspconfig.cmake.setup {}

            lspconfig.html.setup {}

            lspconfig.zls.setup {}

            lspconfig.tinymist.setup {
                settings = {
                    formatterMode = "typstyle",
                    exportPdf = "onType",
                    semanticTokens = "disable",
                },
            }
        end,
    },

    -- TODO: fix java installation
    "mfussenegger/nvim-jdtls",

    {
        "barreiroleo/ltex_extra.nvim",
        ft = { "markdown", "tex", "bib" },
        dependencies = { "neovim/nvim-lspconfig" },
        -- yes, you can use the opts field, just I'm showing the setup explicitly
        config = function()
            require("ltex_extra").setup {
                load_langs = { "en-US", "de-DE" },
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
