vim.opt.wrap = true

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("moellh", { clear = false }),
    callback = function(e)
        local opts = { buffer = e.buf }

        local pretty_hover = require "pretty_hover"
        vim.keymap.set("n", "K", function()
            pretty_hover.hover()
        end, opts)
    end,
})

-- switch between header (in include) and source file (in src)
vim.api.nvim_buf_set_keymap(0, "n", "<leader>lc", "", {
    noremap = true,
    silent = true,
    callback = function()
        local filename = vim.fn.expand "%:t"
        local path = vim.fn.expand "%:p:h"
        local new_path, new_file

        if filename:match "%.hpp$" then
            new_path = path:gsub("include", "src")
            new_file = new_path .. "/" .. filename:gsub("%.hpp$", ".cpp")
        elseif filename:match "%.cpp$" then
            new_path = path:gsub("src", "include")
            new_file = new_path .. "/" .. filename:gsub("%.cpp$", ".hpp")
        else
            print "Not a .cpp or .hpp file"
            return
        end

        if vim.fn.filereadable(new_file) == 1 then
            vim.cmd("e " .. new_file)
        else
            print("File not found: " .. new_file)
        end
    end,
})
