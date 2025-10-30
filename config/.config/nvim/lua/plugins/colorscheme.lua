-- Comand to switch to light mode or dark mode
function LIGHT()
    vim.cmd "set background=light"
end
function DARK()
    vim.cmd "set background=dark"
end

return {

    {
        -- My color scheme, a bit modified
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
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
                custom_highlights = function(colors)
                    return {
                        -- Disable TODO, NOTE, etc. being highlighted automatically
                        ["@comment.error"] = { link = "Comment" },
                        ["@comment.warning"] = { link = "Comment" },
                        ["@comment.hint"] = { link = "Comment" },
                        ["@comment.todo"] = { link = "Comment" },
                        ["@comment.note"] = { link = "Comment" },
                    }
                end,
            }
        end,
    },
}
