-- not text-wrapping
vim.opt.wrap = false

-- if wrap = true, keep indentation on wrapped lines
vim.opt.breakindent = true

-- offset cursor from window edge
vim.opt.scrolloff = 8

function LIGHT()
    vim.cmd "set background=light"
end

function DARK()
    vim.cmd "set background=dark"
end

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

    {
        --[[
        prefered default, dark mode colorscheme
        --]]

        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            -- manually select colorscheme based on kitty theme
            -- otherwise flickering on startup of Catppuccin-Latte theme
            -- local kitty_theme = vim.fn.system [[\
            --     grep '# name' ~/.config/kitty/current-theme.conf | \
            --     awk 'BEGIN { ORS = "" } {print $3}'
            -- ]]
            -- if kitty_theme == "Catppuccin-Latte" then
            --     vim.cmd.colorscheme "catppuccin-latte"
            -- else
            --     vim.cmd.colorscheme "catppuccin-mocha"
            -- end

            -- choose this colorscheme
            require("catppuccin").setup {
                background = { -- :h background
                    light = "latte",
                    dark = "mocha",
                },
                color_overrides = {
                    mocha = {
                        rosewater = "#f5e0dc",
                        flamingo = "#f2cdcd",
                        pink = "#f5c2e7",
                        mauve = "#cba6f7",
                        red = "#f38ba8",
                        maroon = "#eba0ac",
                        peach = "#fab387",
                        yellow = "#f9e2af",
                        green = "#a6e3a1",
                        teal = "#94e2d5",
                        sky = "#89dceb",
                        sapphire = "#74c7ec",
                        blue = "#89b4fa",
                        lavender = "#b4befe",
                        text = "#cdd6f4",
                        subtext1 = "#bac2de",
                        subtext0 = "#a6adc8",
                        overlay2 = "#9399b2",
                        overlay1 = "#7f849c",
                        overlay0 = "#6c7086",
                        surface2 = "#585b70",
                        surface1 = "#45475a",
                        surface0 = "#313244",
                        base = "#000000", -- "#1e1e2e",
                        mantle = "#000000",
                        crust = "#000000",
                    },
                    latte = {
                        rosewater = "#cc7983",
                        flamingo = "#bb5d60",
                        pink = "#d54597",
                        mauve = "#a65fd5",
                        red = "#b7242f",
                        maroon = "#db3e68",
                        peach = "#e46f2a",
                        yellow = "#bc8705",
                        green = "#1a8e32",
                        teal = "#00a390",
                        sky = "#089ec0",
                        sapphire = "#0ea0a0",
                        blue = "#017bca",
                        lavender = "#8584f7",
                        text = "#444444",
                        subtext1 = "#555555",
                        subtext0 = "#666666",
                        overlay2 = "#777777",
                        overlay1 = "#888888",
                        overlay0 = "#999999",
                        surface2 = "#aaaaaa",
                        surface1 = "#bbbbbb",
                        surface0 = "#cccccc",
                        base = "#ffffff",
                        mantle = "#eeeeee",
                        crust = "#dddddd",
                    },
                },
            }
        end,
    },

    { -- indentation guides even on blank lines
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {},
    },

    -- 'nvim-treesitter/nvim-treesitter-context',

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
        "norcalli/nvim-colorizer.lua",
    },
}
