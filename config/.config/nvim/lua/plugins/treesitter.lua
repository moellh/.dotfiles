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

                    if vim.tbl_contains(require("nvim-treesitter").get_installed("parsers"), ft) then
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
}
