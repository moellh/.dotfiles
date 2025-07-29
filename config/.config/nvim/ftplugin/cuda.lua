vim.opt.wrap = true

vim.api.nvim_buf_set_keymap(0, "n", "<leader>lc", "", {
    noremap = true,
    silent = true,
    callback = function()
        local filename = vim.fn.expand "%:t"
        local path = vim.fn.expand "%:p:h"
        local new_path, new_file

        if filename:match "%.cuh$" then
            new_path = path:gsub("include", "src")
            new_file = new_path .. "/" .. filename:gsub("%.cuh$", ".cu")
        elseif filename:match "%.cu$" then
            new_path = path:gsub("src", "include")
            new_file = new_path .. "/" .. filename:gsub("%.cu$", ".cuh")
        end

        if vim.fn.filereadable(new_file) == 1 then
            vim.cmd("e " .. new_file)
        else
            print("File not found: " .. new_file)
        end
    end,
})
