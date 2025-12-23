-- not text-wrapping
vim.opt.wrap = false

-- if wrap = true, keep indentation on wrapped lines
vim.opt.breakindent = true

-- offset cursor from window edge
vim.opt.scrolloff = 8

-- set global statusline
vim.opt.laststatus = 3

package.path = package.path
    .. ";"
    .. vim.fn.expand "$HOME"
    .. "/.luarocks/share/lua/5.1/?/init.lua"
package.path = package.path
    .. ";"
    .. vim.fn.expand "$HOME"
    .. "/.luarocks/share/lua/5.1/?.lua"

-- keymaps for zooming in and out of splits
vim.keymap.set("n", "<leader>zi", ":tab split<CR>", {})
vim.keymap.set("n", "<leader>zo", ":tab close<CR>", {})

return {

    { -- indentation guides even on blank lines
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {},
    },

    "folke/twilight.nvim",

    {
        "folke/zen-mode.nvim",
        config = function()
            vim.keymap.set("n", "<leader>zz", function()
                require("zen-mode").setup {
                    window = {
                        width = 80,
                        options = {},
                    },
                }
                require("zen-mode").toggle()
                vim.wo.wrap = false
                vim.wo.number = false
                vim.wo.rnu = false
                vim.opt.list = false
                vim.opt.scrolloff = 0
                vim.opt.colorcolumn = ""
            end)
        end,
    },

    {
        "3rd/image.nvim",
        enabled = false,
        config = function()
            require("image").setup {
                backend = "kitty",
                integrations = {
                    markdown = {
                        only_render_image_at_cursor = true,
                    },
                },
                tmux_show_only_in_active_window = true,
                kitty_method = "normal",
            }
        end,
    },

    {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        enabled = false,
        opts = {
            file_types = { "markdown", "Avante" },
            only_render_image_at_cursor = true,
        },
        ft = { "markdown", "Avante" },
    },

    {
        "hat0uma/csvview.nvim",
        config = function()
            require("csvview").setup()
        end,
    },

    {
        "SmiteshP/nvim-navic",
        dependencies = { "neovim/nvim-lspconfig" },
    },

    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "SmiteshP/nvim-navic",
        },
        config = function()
            local navic = require "nvim-navic"
            require("lualine").setup {
                options = {
                    icons_enabled = true,
                    theme = "auto",
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    disabled_filetypes = {
                        statusline = {},
                        winbar = {},
                    },
                    ignore_focus = {},
                    always_divide_middle = true,
                    always_show_tabline = true,
                    globalstatus = true,
                    refresh = {
                        statusline = 100,
                        tabline = 100,
                        winbar = 100,
                    },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = {
                        function()
                            return navic.get_location()
                        end,
                    },
                    lualine_x = { "filename" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
                tabline = {},
                extensions = {},
            }
        end,
    },

    {
        "Fildo7525/pretty_hover",
        event = "LspAttach",
        opts = {},
    },

    {
        "catgoose/nvim-colorizer.lua",
        event = "BufReadPre",
        config = function()
            require("colorizer").setup()
        end,
    },
}
