-- Last modified: 2026-11-23
-- Jupyter notebook plugins

-- Description: Edit and run .ipynb notebooks: jupytext.nvim shows them as
--   markdown with ```python code blocks, otter.nvim gives the code blocks
--   pyright, molten-nvim runs them in a Jupyter kernel, image.nvim (ui.lua)
--   draws plots inline.
--   Kernel handling and keymaps (<leader>j*) in lua/core/notebook.lua,
--   attached in ftplugin/markdown.lua

-- Git repos:
--   molten-nvim: https://github.com/benlubas/molten-nvim
--   jupytext.nvim: https://github.com/goerz/jupytext.nvim
--   otter.nvim: https://github.com/jmbuhr/otter.nvim

-- Python side, system packages (packages.txt):
--   python-pynvim: remote plugin host for molten (jupyter_client, nbformat,
--     pillow, requests and websocket-client come with jupyterlab)
--   python-jupytext: the jupytext CLI
--   molten's optional output renderers: python-cairosvg (SVG),
--     python-pyperclip (clipboard)
--   Left out, molten then shows these outputs as text:
--     plotly figures as images need python-plotly + python-kaleido-bin, whose
--     deps choreographer and logistro aren't packaged (PyPI only), plus
--     python-simplejson
--     LaTeX outputs as images need python-pnglatex, broken on Python 3.13+
--     (crashes molten, leaves .aux/.log/.pdf files in the cwd)
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
            vim.g.molten_virt_lines_off_by_1 = true -- below the closing ```
            vim.g.molten_wrap_output = true
            vim.g.molten_output_win_max_height = 20
        end,
    },

    {
        "goerz/jupytext.nvim",
        lazy = false, -- its BufReadCmd must exist before the first .ipynb opens
        opts = {
            format = "markdown",
            -- no paired .py/.md notebooks here, keep its autocmds off them
            sync_patterns = {},
        },
    },

    -- LSP inside the code blocks: mirrors them into hidden <file>.otter.py
    -- buffers that pyright attaches to, activated in ftplugin/markdown.lua
    {
        "jmbuhr/otter.nvim",
        lazy = true,
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = {
            lsp = {
                -- update diagnostics while typing, like a normal buffer
                diagnostic_update_events = {
                    "BufWritePost",
                    "InsertLeave",
                    "TextChanged",
                },
            },
        },
    },
}
