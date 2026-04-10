-- LTeX Plus language server configuration
-- Provides spell checking and grammar for multiple document formats
-- Requires: ltex-ls-plus (pacman -S ltex-ls-plus)
--
-- Code actions (gra): Add to dictionary, Disable rule, Show rule info

local ltex_language_id_mapping = {
    bib = "bibtex",
    pandoc = "markdown",
    plaintex = "tex",
    rnoweb = "rsweave",
    rst = "restructuredtext",
    tex = "latex",
    text = "plaintext",
}

return {
    cmd = { "ltex-ls-plus" },
    filetypes = {
        "bib",
        "context",
        "gitcommit",
        "html",
        "markdown",
        "org",
        "pandoc",
        "plaintex",
        "quarto",
        "rmd",
        "rnoweb",
        "rst",
        "tex",
        "text",
        "typst",
        "xhtml",
    },
    root_markers = { ".git" },
    single_file_support = true,
    get_language_id = function(_, filetype)
        return ltex_language_id_mapping[filetype] or filetype
    end,
    settings = {
        ltex = {
            language = "auto",
            enabled = {
                "bib",
                "context",
                "gitcommit",
                "html",
                "markdown",
                "org",
                "pandoc",
                "plaintex",
                "quarto",
                "rmd",
                "rnoweb",
                "rst",
                "tex",
                "text",
                "typst",
                "xhtml",
            },
        },
    },
    on_attach = function(_, _)
        -- Load ltex_extra for code actions (gra)
        require("ltex_extra").setup {
            load_langs = { "en-US", "de-DE" },
            init_check = true,
            path = vim.fn.stdpath("data") .. "/ltex",
            log_level = "none",
        }
    end,
}
