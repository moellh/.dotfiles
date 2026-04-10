-- Last modified: 2026-04-10
-- UI and appearance plugins

-- Description: Colorscheme, visual guides, statusline, notifications, keybindings popup

-- Git repos:
--   catppuccin: https://github.com/catppuccin/nvim
--   indent-blankline: https://github.com/lukas-reineke/indent-blankline.nvim
--   twilight: https://github.com/folke/twilight.nvim
--   zen-mode: https://github.com/folke/zen-mode.nvim
--   lualine: https://github.com/nvim-lualine/lualine.nvim
--   nvim-navic: https://github.com/SmiteshP/nvim-navic
--   image.nvim: https://github.com/3rd/image.nvim
--   render-markdown: https://github.com/MeanderingProgrammer/render-markdown.nvim
--   csvview: https://github.com/hat0uma/csvview.nvim
--   noice.nvim: https://github.com/folke/noice.nvim
--   which-key: https://github.com/folke/which-key.nvim
--   obsidian.nvim: https://github.com/epwalsh/obsidian.nvim

vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.scrolloff = 8
vim.opt.laststatus = 3
vim.wo.conceallevel = 2

package.path = package.path .. ";" .. vim.fn.expand "$HOME" .. "/.luarocks/share/lua/5.1/?/init.lua"
package.path = package.path .. ";" .. vim.fn.expand "$HOME" .. "/.luarocks/share/lua/5.1/?.lua"

vim.keymap.set("n", "<leader>zi", ":tab split<CR>", {})
vim.keymap.set("n", "<leader>zo", ":tab close<CR>", {})

return {

    -- Colorscheme
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            background = {
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
                    base = "#000000",
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
            custom_highlights = function(colors)
                return {
                    ["@comment.error"] = { link = "Comment" },
                    ["@comment.warning"] = { link = "Comment" },
                    ["@comment.hint"] = { link = "Comment" },
                    ["@comment.todo"] = { link = "Comment" },
                    ["@comment.note"] = { link = "Comment" },
                    DoneHighlight = { reverse = true, bold = true },
                    WinSeparator = { fg = colors.surface2, bg = colors.base },
                    NoicePopup = { bg = colors.base },
                    NoicePopupBorder = { fg = colors.surface2, bg = colors.base },
                    NoiceCmdlinePopup = { bg = colors.base },
                    NoiceCmdlinePopupBorder = { fg = colors.blue, bg = colors.base },
                    NoiceCmdlinePopupBorderSearch = { fg = colors.peach, bg = colors.base },
                    NoiceCmdlineIcon = { fg = colors.blue },
                    NoiceCmdlineIconSearch = { fg = colors.peach },
                    NoiceSplit = { bg = colors.base },
                    NoiceSplitBorder = { fg = colors.surface2, bg = colors.base },
                    NoiceMini = { bg = colors.base },
                    NoiceVirtualText = { fg = colors.subtext0 },
                    NoiceFormatLevelError = { fg = colors.red },
                    NoiceFormatLevelWarn = { fg = colors.yellow },
                    NoiceFormatLevelInfo = { fg = colors.blue },
                    NoiceConfirmBorder = { fg = colors.blue, bg = colors.base },
                    NoicePopupmenuBorder = { fg = colors.surface2, bg = colors.base },
                    NoicePopupmenuSelected = { bg = colors.surface1, fg = colors.text },
                    NoiceScrollbarThumb = { bg = colors.overlay0 },
                    NoiceScrollbar = { bg = colors.surface1 },
                }
            end,
        },
        config = function(_, opts)
            require("catppuccin").setup(opts)
            local augroup = vim.api.nvim_create_augroup("DoneHighlightGroup", { clear = true })
            vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
                group = augroup,
                pattern = "*",
                callback = function()
                    vim.fn.matchadd("DoneHighlight", "\\v<DONE:>")
                end,
            })
        end,
    },

    -- Indent guides
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {},
    },

    -- Focus mode
    "folke/twilight.nvim",

    {
        "folke/zen-mode.nvim",
        config = function()
            vim.keymap.set("n", "<leader>zz", function()
                require("zen-mode").setup {
                    window = { width = 80, options = {} },
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

    -- Image support
    {
        "3rd/image.nvim",
        enabled = false,
        config = function()
            require("image").setup {
                backend = "kitty",
                integrations = { markdown = { only_render_image_at_cursor = true } },
                tmux_show_only_in_active_window = true,
                kitty_method = "normal",
            }
        end,
    },

    -- Markdown rendering
    {
        "MeanderingProgrammer/render-markdown.nvim",
        enabled = false,
        opts = {
            file_types = { "markdown", "Avante" },
            only_render_image_at_cursor = true,
        },
        ft = { "markdown", "Avante" },
    },

    -- CSV viewer
    {
        "hat0uma/csvview.nvim",
        config = function()
            require("csvview").setup()
        end,
    },

    -- Navic for winbar
    {
        "SmiteshP/nvim-navic",
        dependencies = { "neovim/nvim-lspconfig" },
    },

    -- Statusline
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
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    disabled_filetypes = { statusline = {}, winbar = {} },
                    ignore_focus = {},
                    always_divide_middle = true,
                    always_show_tabline = true,
                    globalstatus = true,
                    refresh = { statusline = 100, tabline = 100, winbar = 100 },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { function() return navic.get_location() end },
                    lualine_x = { "filename" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
                tabline = {},
                extensions = {},
            }
        end,
    },

    -- Noice UI replacement
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            cmdline = {
                enabled = true,
                view = "cmdline_popup",
                opts = {},
                format = {
                    cmdline = { pattern = "^:", icon = "", lang = "vim" },
                    search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
                    search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
                    filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
                    lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
                    help = { pattern = "^:%s*he?l?p?%s+", icon = "?" },
                    input = { view = "cmdline_input", icon = " " },
                },
            },
            messages = {
                enabled = true,
                view = "mini",
                view_error = "mini",
                view_warn = "mini",
                view_history = "messages",
                view_search = "virtualtext",
            },
            popupmenu = {
                enabled = true,
                backend = "nui",
                kind_icons = {},
            },
            redirect = { view = "popup", filter = { event = "msg_show" } },
            commands = {
                history = { view = "split", opts = { enter = true, format = "details" }, filter = { any = { { event = "notify" }, { error = true }, { warning = true }, { event = "msg_show", kind = { "" } }, { event = "lsp", kind = "message" } } } },
                last = { view = "popup", opts = { enter = true, format = "details" }, filter = { any = { { event = "notify" }, { error = true }, { warning = true }, { event = "msg_show", kind = { "" } }, { event = "lsp", kind = "message" } } }, filter_opts = { count = 1 } },
                errors = { view = "popup", opts = { enter = true, format = "details" }, filter = { error = true }, filter_opts = { reverse = true } },
                all = { view = "split", opts = { enter = true, format = "details" }, filter = {} },
            },
            notify = { enabled = true, view = "notify" },
            lsp = {
                progress = { enabled = true, format = "lsp_progress", format_done = "lsp_progress_done", throttle = 1000 / 30, view = "mini" },
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
                    ["vim.lsp.util.stylize_markdown"] = false,
                    ["cmp.entry.get_documentation"] = false,
                },
                hover = { enabled = true, silent = false, view = nil, opts = {} },
                signature = { enabled = true, auto_open = { enabled = true, trigger = true, luasnip = true, throttle = 50 }, view = nil, opts = {} },
                message = { enabled = true, view = "notify", opts = {} },
                documentation = { view = "hover", opts = { lang = "markdown", replace = true, render = "plain", format = { "{message}" }, win_options = { concealcursor = "n", conceallevel = 3 } } },
            },
            markdown = {
                hover = { ["|(%S-)|"] = vim.cmd.help, ["%[.-%]%((%S-)%)"] = require("noice.util").open },
                highlights = { ["|%S-|"] = "@text.reference", ["@%S+"] = "@parameter", ["^%s*(Parameters:)"] = "@text.title", ["^%s*(Return:)"] = "@text.title", ["^%s*(See also:)"] = "@text.title", ["{%S-}"] = "@parameter" },
            },
            health = { checker = true },
            presets = {
                bottom_search = false,
                command_palette = false,
                long_message_to_split = false,
                inc_rename = false,
                lsp_doc_border = false,
            },
            throttle = 1000 / 30,
            views = {
                mini = { win_options = { winblend = 0, winhighlight = "Normal:NormalFloat" }, position = { row = -2, col = "100%" }, size = { width = "auto", height = "auto" } },
            },
            routes = {
                { filter = { event = "msg_show", find = "%d+ lines? %a+ed" }, opts = { skip = true } },
                { filter = { event = "msg_show", find = "%d+ %a+ lines" }, opts = { skip = true } },
                { filter = { event = "msg_show", find = "written" }, opts = { skip = true } },
                { filter = { event = "msg_show", find = "search hit" }, opts = { skip = true } },
            },
            status = {},
            format = {},
        },
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
    },

    -- Keybindings popup
    {
        'folke/which-key.nvim',
        event = 'VeryLazy',
        opts = {},
        keys = {},
    },

    -- Obsidian integration
    {
        "epwalsh/obsidian.nvim",
        version = "*",
        lazy = true,
        event = {
            "BufReadPre " .. vim.fn.expand "~" .. "/documents/devault/**/*.md",
            "BufNewFile " .. vim.fn.expand "~" .. "/documents/devault/**/*.md",
        },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            workspaces = { { name = "devault", path = "~/documents/devault" } },
            completion = { nvim_cmp = true, min_chars = 0 },
            ui = { bullets = {} },
        },
    },
}
