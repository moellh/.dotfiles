return {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    -- root_dir instead of root_markers: nvim-lspconfig's lsp/pyright.lua comes
    -- later in 'runtimepath' and its root_markers would replace ours.
    -- Nearest of the first group wins, so a project with only a .venv (like a
    -- course exercise folder) still gets its own root
    root_dir = function(bufnr, on_dir)
        on_dir(vim.fs.root(bufnr, {
            {
                "pyrightconfig.json",
                "pyproject.toml",
                "setup.py",
                "setup.cfg",
                "requirements.txt",
                "Pipfile",
                ".venv",
            },
            ".git",
        }))
    end,
    -- Use the project's .venv so its packages resolve without activating it
    on_init = function(client)
        local python = client.root_dir
            and vim.fs.joinpath(client.root_dir, ".venv", "bin", "python")
        if python and vim.uv.fs_stat(python) then
            client.settings = vim.tbl_deep_extend(
                "force",
                client.settings,
                { python = { pythonPath = python } }
            )
            client:notify(
                "workspace/didChangeConfiguration",
                { settings = client.settings }
            )
        end
    end,
}
