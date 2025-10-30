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
                    -- "nil_ls", -- Nix TODO: enable again later, currently broken and not needed
                    "pyright", -- Python
                    "rust_analyzer", -- Rust
                    "texlab", -- Latex
                    "tinymist", -- Typst
                    "ts_ls", -- Javascript, Typescript
                },
            }

            local navic = require "nvim-navic"

            -- Helper function for on_attach with navic
            local function on_attach_navic(client, bufnr)
                navic.attach(client, bufnr)
            end

            -- Python
            vim.lsp.config.pyright = {
                cmd = { "pyright-langserver", "--stdio" },
                filetypes = { "python" },
                root_markers = {
                    "pyproject.toml",
                    "setup.py",
                    "setup.cfg",
                    "requirements.txt",
                    "Pipfile",
                    ".git",
                },
                on_attach = on_attach_navic,
            }

            -- Lua
            vim.lsp.config.lua_ls = {
                cmd = { "lua-language-server" },
                filetypes = { "lua" },
                root_markers = {
                    ".luarc.json",
                    ".luarc.jsonc",
                    ".luacheckrc",
                    ".stylua.toml",
                    "stylua.toml",
                    "selene.toml",
                    "selene.yml",
                    ".git",
                },
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = "Replace",
                        },
                        diagnostics = {
                            globals = { "vim" },
                        },
                    },
                },
                on_attach = on_attach_navic,
            }

            -- TypeScript/JavaScript
            vim.lsp.config.ts_ls = {
                cmd = { "typescript-language-server", "--stdio" },
                filetypes = {
                    "javascript",
                    "javascriptreact",
                    "javascript.jsx",
                    "typescript",
                    "typescriptreact",
                    "typescript.tsx",
                },
                root_markers = {
                    "package.json",
                    "tsconfig.json",
                    "jsconfig.json",
                    ".git",
                },
                on_attach = on_attach_navic,
            }

            -- Markdown
            vim.lsp.config.marksman = {
                cmd = { "marksman", "server" },
                filetypes = { "markdown", "markdown.mdx" },
                root_markers = { ".marksman.toml", ".git" },
                on_attach = on_attach_navic,
            }

            -- LaTeX
            vim.lsp.config.texlab = {
                cmd = { "texlab" },
                filetypes = { "tex", "plaintex", "bib" },
                root_markers = {
                    ".latexmkrc",
                    ".texlabroot",
                    "texlabroot",
                    "Tectonic.toml",
                    "Makefile",
                    ".git",
                },
            }

            -- LTeX (spell checker)
            vim.lsp.config.ltex = {
                cmd = { "ltex-ls" },
                filetypes = {
                    "bib",
                    "gitcommit",
                    "markdown",
                    "org",
                    "plaintex",
                    "rst",
                    "rnoweb",
                    "tex",
                    "pandoc",
                },
                root_markers = { ".git" },
                settings = {
                    ltex = {},
                },
                on_attach = on_attach_navic,
            }

            -- Bash
            vim.lsp.config.bashls = {
                cmd = { "bash-language-server", "start" },
                filetypes = { "sh", "bash" },
                root_markers = { ".git" },
                on_attach = on_attach_navic,
            }

            -- Clangd (C/C++)
            vim.lsp.config.clangd = {
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
                filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
                root_markers = {
                    "compile_commands.json",
                    ".clangd",
                    ".clang-format",
                    ".git",
                },
                init_options = {
                    clangdFileStatus = true,
                },
                on_attach = on_attach_navic,
            }

            -- Rust
            vim.lsp.config.rust_analyzer = {
                cmd = { "rust-analyzer" },
                filetypes = { "rust" },
                root_markers = { "Cargo.toml", "rust-project.json" },
            }

            -- CMake
            vim.lsp.config.cmake = {
                cmd = { "cmake-language-server" },
                filetypes = { "cmake" },
                root_markers = {
                    "CMakePresets.json",
                    "CTestConfig.cmake",
                    ".git",
                    "build",
                    "cmake",
                },
            }

            -- HTML
            vim.lsp.config.html = {
                cmd = { "vscode-html-language-server", "--stdio" },
                filetypes = { "html", "templ" },
                root_markers = { "package.json", ".git" },
            }

            -- Zig
            vim.lsp.config.zls = {
                cmd = { "zls" },
                filetypes = { "zig", "zir" },
                root_markers = { "zls.json", "build.zig", ".git" },
            }

            -- Typst
            vim.lsp.config.tinymist = {
                cmd = { "tinymist" },
                filetypes = { "typst" },
                root_markers = { "main.typ", ".git" },
                settings = {
                    formatterMode = "typstyle",
                    exportPdf = "onType",
                    semanticTokens = "disable",
                },
            }

            -- Enable all configured LSP servers
            vim.lsp.enable {
                "pyright",
                "lua_ls",
                "ts_ls",
                "marksman",
                "texlab",
                "ltex",
                "bashls",
                "clangd",
                "rust_analyzer",
                "cmake",
                "html",
                "zls",
                "tinymist",
            }
        end,
    },

    -- TODO: fix java installation
    "mfussenegger/nvim-jdtls",

    {
        "barreiroleo/ltex_extra.nvim",
        enabled = false,
        ft = { "markdown", "tex", "bib" },
        dependencies = { "neovim/nvim-lspconfig" },
        -- yes, you can use the opts field, just I'm showing the setup explicitly
        config = function()
            require("ltex_extra").setup {
                load_langs = { "en-US", "de-DE" },
                -- your_ltex_extra_opts,
            }
        end,
    },
}
