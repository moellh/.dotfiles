-- ...

return {
    {
        "lervag/vimtex",
        lazy = false,
        init = function() -- config
            vim.g.vimtex_view_general_viewer = 'okular'
            vim.g.vimtex_view_general_options = '--unique file:@pdf\\#src:@line@tex'

            -- don't show quickfix window after compilation
            vim.g.vimtex_quickfix_mode = 0
        end,
        keys = {
            { "<leader>rl", "<Plug>(vimtex-compile)" },
            { "<leader>lv", "<Plug>(vimtex-view)" },
        },
    },
}
