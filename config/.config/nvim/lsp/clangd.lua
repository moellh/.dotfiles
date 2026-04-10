return {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--log=verbose",
        "--limit-results=0",
        "--suggest-missing-includes",
        "--function-arg-placeholders",
        "--all-scopes-completion",
        "--completion-style=bundled",
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    root_markers = {
        "compile_commands.json",
        ".clangd",
        ".clang-format",
        ".git",
    },
    init_options = {
        clangdFileStatus = true,
    },
}
