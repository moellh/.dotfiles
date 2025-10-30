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

-- Switch between header (in include) and source file (in src).
-- Searches for multiple common C++ and CUDA extensions.
vim.api.nvim_buf_set_keymap(0, "n", "<leader>lc", "", {
    noremap = true,
    silent = true,
    callback = function()
        -- Get the current filename root and path (directory)
        local current_file = vim.fn.expand "%"
        local filename_no_ext = vim.fn.expand "%:t:r" -- e.g. "file"
        local current_dir = vim.fn.expand "%:p:h" -- e.g. "/project/src" or "/project/include"

        local new_file = nil
        local target_exts = {}
        local current_ext = vim.fn.expand "%:e"

        -- Define possible target extensions based on the current file type
        if
            current_file:match "%.hpp?$"
            or current_file:match "%.hh?$"
            or current_file:match "%.cuh$"
        then
            -- Current file is a Header (.h, .hpp, .hh, .cuh)
            target_exts = { ".cpp", ".c", ".cu" }
        elseif
            current_file:match "%.cpp$"
            or current_file:match "%.c$"
            or current_file:match "%.cu$"
        then
            -- Current file is a Source (.cpp, .c, .cu)
            target_exts = { ".h", ".hpp", ".cuh" }
        else
            -- Not a C++ or CUDA file
            print "Not a C/C++ or CUDA source/header file."
            return
        end

        -- Function to check for a file in a given directory/extension list
        local function find_alternate_file(base_path, extensions)
            for _, ext in ipairs(extensions) do
                local candidate = base_path .. "/" .. filename_no_ext .. ext
                if vim.fn.filereadable(candidate) == 1 then
                    return candidate, ext
                end
            end
            return nil
        end

        -- 1. Check if the alternate file is in the same directory
        new_file = find_alternate_file(current_dir, target_exts)

        -- 2. If not found, check the standard C++ layout (src <-> include)
        if not new_file then
            if current_dir:match "/include$" then
                local alternate_dir = current_dir:gsub("/include$", "/src")
                new_file = find_alternate_file(alternate_dir, target_exts)
            elseif current_dir:match "/src$" then
                local alternate_dir = current_dir:gsub("/src$", "/include")
                new_file = find_alternate_file(alternate_dir, target_exts)
            end
        end

        -- Execute the file switch or print an error
        if new_file then
            vim.cmd("e " .. new_file)
        else
            local targets = table.concat(target_exts, ", ")
            print(
                "Alternate file not found (checked: "
                    .. targets
                    .. ") in standard locations."
            )
        end
    end,
})
