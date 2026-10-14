-- rust-analyzer is started by rustaceanvim (lua/plugins/coding/lsp.lua), which
-- merges this vim.lsp.config["rust-analyzer"] table into its own config and
-- finds the cargo workspace root itself. Do not vim.lsp.enable() it.
-- Install: rustup component add rust-analyzer (matches the toolchain's rustc)

return {
    settings = {
        ["rust-analyzer"] = {
            -- Show clippy warnings, not only rustc ones
            check = { command = "clippy" },
            -- Build into target/rust-analyzer/, so checks don't wait on the
            -- lock of a cargo build running in a terminal
            cargo = { targetDir = true },
            inlayHints = {
                closureReturnTypeHints = { enable = "with_block" },
                lifetimeElisionHints = { enable = "skip_trivial" },
            },
        },
    },
}
