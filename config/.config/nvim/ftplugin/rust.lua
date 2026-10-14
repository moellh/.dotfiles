-- Rust keymaps for rustaceanvim commands (see :h rustaceanvim)

local function map(lhs, args, desc)
    vim.keymap.set("n", lhs, function()
        vim.cmd.RustLsp(args)
    end, { buffer = 0, silent = true, desc = desc })
end

map("gra", "codeAction", "Code action (grouped)")
map("K", { "hover", "actions" }, "Hover with actions")
map("<leader>re", { "explainError", "current" }, "[R]ust [E]xplain error")
map("<leader>rd", { "renderDiagnostic", "current" }, "[R]ust render [D]iagnostic")
map("<leader>rm", "expandMacro", "[R]ust expand [M]acro")
map("<leader>rl", "run", "[R]ust run target at [L]ine")
map("<leader>rr", "runnables", "[R]ust [R]unnables")
map("<leader>rt", "testables", "[R]ust [T]estables")
map("<leader>rD", "debuggables", "[R]ust [D]ebuggables")
map("<leader>rc", "openCargo", "[R]ust open [C]argo.toml")
map("<leader>rp", "parentModule", "[R]ust [P]arent module")
