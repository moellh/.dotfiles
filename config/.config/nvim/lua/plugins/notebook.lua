-- Last modified: 2026-11-23
-- Jupyter notebook plugins

-- Description: Edit and run .ipynb notebooks: jupytext.nvim shows them as
--   py:percent text (ft=python, so pyright/black/dap just work), molten-nvim
--   runs cells in a Jupyter kernel, image.nvim (ui.lua) draws plots inline.
--   Kernel handling and keymaps (<leader>j*) in lua/core/notebook.lua

-- Git repos:
--   molten-nvim: https://github.com/benlubas/molten-nvim
--   jupytext.nvim: https://github.com/goerz/jupytext.nvim

-- Python side, system packages (packages.txt):
--   python-pynvim: remote plugin host for molten (jupyter_client, nbformat,
--     pillow, requests and websocket-client come with jupyterlab)
--   python-jupytext: the jupytext CLI
--   molten's optional output renderers: python-cairosvg (SVG),
--     python-pnglatex (LaTeX), python-plotly + python-kaleido-bin (plotly),
--     python-pyperclip (clipboard)
-- After installing or updating molten: :UpdateRemotePlugins (done by build)

return {

    {
        "benlubas/molten-nvim",
        version = "^1.0.0", -- breaking changes only in 2.x
        build = ":UpdateRemotePlugins",
        dependencies = { "3rd/image.nvim" },
        init = function()
            -- Always the system python with pynvim, never an activated .venv
            vim.g.python3_host_prog = "/usr/bin/python3"

            vim.g.molten_image_provider = "image.nvim"
            vim.g.molten_auto_open_output = false -- <leader>jo opens it
            vim.g.molten_virt_text_output = true -- output stays below the cell
            vim.g.molten_wrap_output = true
            vim.g.molten_output_win_max_height = 20
        end,
    },

    {
        "goerz/jupytext.nvim",
        lazy = false, -- its BufReadCmd must exist before the first .ipynb opens
        opts = {
            format = "py:percent",
            -- no paired .py/.md notebooks here, keep its autocmds off them
            sync_patterns = {},
        },
    },
}
