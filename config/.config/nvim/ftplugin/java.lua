vim.opt.wrap = true
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4

-- Java LSP (JDTLS) Configuration
-- Requires: yay -S jdtls

local jdtls = require("jdtls")

-- Find root directory
local root_dir = vim.fs.dirname(
    vim.fs.find({ "gradlew", ".git", "mvnw", "pom.xml", "build.gradle" }, { upward = true })[1]
) or vim.fn.getcwd()

-- Workspace directory (separate workspace per project)
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

-- Optional: java-debug and vscode-java-test bundles for debugging/testing
-- Install with: yay -S java-debug vscode-java-test (or clone and build manually)
local bundles = {}
local java_debug_path = vim.fn.glob("/usr/share/java-debug/com.microsoft.java.debug.plugin-*.jar", 1)
if java_debug_path ~= "" then
    table.insert(bundles, java_debug_path)
end

-- Add vscode-java-test jars if available
local vscode_test_path = "/usr/share/vscode-java-test/server"
if vim.fn.isdirectory(vscode_test_path) == 1 then
    for _, jar in ipairs(vim.fn.glob(vscode_test_path .. "/*.jar", 1, 1)) do
        local fname = vim.fn.fnamemodify(jar, ":t")
        -- Exclude runner and jacoco jars
        if fname ~= "com.microsoft.java.test.runner-jar-with-dependencies.jar" and fname ~= "jacocoagent.jar" then
            table.insert(bundles, jar)
        end
    end
end

-- Configuration using jdtls wrapper script
local config = {
    cmd = {
        "jdtls",
        "--jvm-arg=-Djava.import.generatesMetadataFilesAtProjectRoot=false",
        "-Xms1g",
        "-Xmx4g",
        "-data", workspace_dir,
    },
    root_dir = root_dir,
    settings = {
        java = {
            format = {
                enabled = true,
                tabSize = 4,
            },
            saveActions = {
                organizeImports = false,
            },
            completion = {
                favoriteStaticMembers = {
                    "org.junit.Assert.*",
                    "org.junit.Assume.*",
                    "org.junit.jupiter.api.Assertions.*",
                    "org.junit.jupiter.api.Assumptions.*",
                    "org.junit.jupiter.api.DynamicContainer.*",
                    "org.junit.jupiter.api.DynamicTest.*",
                    "org.mockito.Mockito.*",
                    "org.mockito.ArgumentMatchers.*",
                    "org.mockito.Answers.*",
                },
            },
            configuration = {
                runtimes = {
                    {
                        name = "JavaSE-21",
                        path = "/usr/lib/jvm/default/",
                    },
                },
            },
        },
    },
    init_options = {
        bundles = bundles,
    },
    capabilities = require("blink.cmp").get_lsp_capabilities(),
    on_attach = function(client, bufnr)
        -- Note: Standard LSP keymaps (gd, gr, K, etc) are set in lsp.lua via LspAttach

        -- Java-specific keymaps (<leader>j* prefix for Java actions)
        vim.keymap.set("n", "<leader>jo", function()
            jdtls.organize_imports()
        end, { buffer = bufnr, desc = "Java: Organize imports" })

        vim.keymap.set("n", "<leader>jv", function()
            jdtls.extract_variable()
        end, { buffer = bufnr, desc = "Java: Extract variable" })

        vim.keymap.set("v", "<leader>jv", function()
            jdtls.extract_variable(true)
        end, { buffer = bufnr, desc = "Java: Extract variable (visual)" })

        vim.keymap.set("n", "<leader>jc", function()
            jdtls.extract_constant()
        end, { buffer = bufnr, desc = "Java: Extract constant" })

        vim.keymap.set("v", "<leader>jc", function()
            jdtls.extract_constant(true)
        end, { buffer = bufnr, desc = "Java: Extract constant (visual)" })

        vim.keymap.set("v", "<leader>jm", function()
            jdtls.extract_method(true)
        end, { buffer = bufnr, desc = "Java: Extract method" })
    end,
}

-- Start or attach to LSP server
jdtls.start_or_attach(config)
