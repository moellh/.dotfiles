-- Last modified: 2026-11-23
-- Jupyter notebook plugins

-- Description: Edit and run .ipynb notebooks: jupytext.nvim shows them as
--   markdown with ```python code blocks, otter.nvim gives the code blocks
--   pyright, molten-nvim runs them in a Jupyter kernel, snacks.nvim draws
--   plots and LaTeX inline (kitty graphics, scrolls with the text).
--   Kernel handling and keymaps (<leader>j*) in lua/core/notebook.lua,
--   attached in ftplugin/markdown.lua, LaTeX sizing in lua/core/md_math.lua

-- Git repos:
--   molten-nvim: https://github.com/benlubas/molten-nvim
--   jupytext.nvim: https://github.com/goerz/jupytext.nvim
--   otter.nvim: https://github.com/jmbuhr/otter.nvim
--   snacks.nvim: https://github.com/folke/snacks.nvim

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
        -- main: the snacks image provider and :MoltenYankOutput came after
        -- the last release (v1.9.2, Jan 2025)
        branch = "main",
        build = ":UpdateRemotePlugins",
        dependencies = { "folke/snacks.nvim" },
        init = function()
            -- Always the system python with pynvim, never an activated .venv
            vim.g.python3_host_prog = "/usr/bin/python3"

            -- snacks pins plots into the text with unicode placeholders, so
            -- they scroll with it (image.nvim drew over the text in tmux)
            vim.g.molten_image_provider = "snacks.nvim"
            vim.g.molten_auto_open_output = false -- <leader>jo opens it
            vim.g.molten_virt_text_output = true -- output stays below the cell
            vim.g.molten_virt_lines_off_by_1 = true -- below the closing ```
            vim.g.molten_wrap_output = true
            vim.g.molten_output_win_max_height = 20

            -- no background on cells that ran: it covered only the code text,
            -- not render-markdown's full width code block background. molten
            -- only links MoltenCell to CursorLine if the group doesn't exist
            vim.api.nvim_set_hl(0, "MoltenCell", {})
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

    -- Images: molten's plots, and LaTeX in the markdown ($...$, $$...$$)
    -- through pdflatex + magick, sized to the text (lua/core/md_math.lua).
    -- Only the image module, attached to notebooks only (core/notebook.lua)
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            image = {
                enabled = true,
                formats = {}, -- don't take over opening image files
                doc = {
                    enabled = false, -- no auto attach to all markdown
                    -- largest plot in cells (molten reads these too)
                    max_width = 100,
                    max_height = 25,
                },
                -- no icon before the line a plot hangs below (the closing
                -- fence): it shifted that line on the cursor line
                icons = { image = "" },
            },
        },
        config = function(_, opts)
            require("snacks").setup(opts)
            require("core.md_math").setup()
        end,
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
