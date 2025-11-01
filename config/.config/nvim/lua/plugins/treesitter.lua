return {

    {
        -- Add treesitter parsers, highlighting, and indentation
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            -- Install all parsers
            require("nvim-treesitter").install "unstable"

            -- Skip buffers with some filetypes
            local ignored_filetypes = {
                -- Neovim
                "", -- no filetype
                "help", -- help page
                "qf", -- quickfix list

                -- generic file types
                "conf",

                -- Telescope
                "TelescopePrompt",
                "TelescopeResults",

                -- Avante
                "AvantePromptInput",
                "AvanteInput",
                "AvanteSelectedFiles",
                "AvanteSelectedCode",
                "AvanteTodos",

                -- Oil
                "oil",
                "oil_preview",

                -- CMP
                "cmp_menu",
                "cmp_docs",

                -- lazy
                "lazy",
                "lazy_backdrop",

                -- Other plugins
                "aerial",
                "undotree",
            }

            -- Enable highlighting
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "*",
                callback = function()
                    local buf = vim.api.nvim_get_current_buf()
                    local ft = vim.bo[buf].filetype
                    if vim.tbl_contains(ignored_filetypes, ft) then
                        return
                    end

                    if ft == "text" then
                        vim.treesitter.start(buf, "markdown")
                        return
                    end

                    vim.treesitter.start(buf)
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
}
