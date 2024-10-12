return {

    -- treesitter-textobjects for language specific selection
    -- see config in nvim-treesitter.configs->textobjects
    -- see list of textobjects by language on github-page
    'nvim-treesitter/nvim-treesitter-textobjects',

    { -- treesitter for functions that require an AST
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup {

                -- default languages to install
                -- list of supported languages at github-page
                ensure_installed = {
                    'c',
                    'lua',
                    'vim',
                    'vimdoc',
                    'query', -- required
                    'bash',
                    'ssh_config', -- unix
                    'git_config',
                    'gitcommit',
                    'gitignore', -- git
                    'html',
                    'css', -- web
                    'javascript',
                    'typescript',
                    'jsdoc',
                    'json', -- js
                    'cpp',
                    'cmake', -- cpp
                    'rust',
                    'java', -- java
                    'python', -- python
                    'latex',
                    'bibtex', -- latex
                    'markdown', -- md
                },

                -- installs language if not already
                auto_install = true,

                sync_install = false,

                indent = {
                    enable = true,
                },

                -- highlights code more precisely
                highlight = {
                    enable = true,
                },

                -- keybinds for selection based on AST
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = '<leader>ss',
                        node_incremental = '<leader>si',
                        scope_incremental = '<leader>sc',
                        node_decremental = '<leader>sd',
                    },
                },

                -- keybinds for selection based on language-specific textobjects
                textobjects = {
                    select = {
                        enable = true,

                        -- enable lookahead to next specified textobject
                        lookahead = true,

                        -- keybinds for selecting textobjects
                        -- see textobjects.scm
                        keymaps = {
                            ['af'] = '@function.outer',
                            ['if'] = '@function.inner',
                            ['ac'] = '@class.outer',
                            ['ic'] = '@class.inner',
                            ['as'] = {
                                query = '@scope',
                                query_group = 'locals',
                            },
                        },

                        -- applied visual-mode for the corresponing textobject
                        selection_modes = {
                            ['@parameter.outer'] = 'v',
                            ['@function.outer'] = 'v',
                            ['@class.outer'] = '<c-v>',
                        },

                        -- adds surrounding whitespaces to selection
                        include_surrounding_whitespace = true,
                    },
                },
            }
        end,
    },
}

--[[
{ -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      -- [[ Configure Treesitter  See `:help nvim-treesitter`

      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'bash', 'c', 'html', 'lua', 'markdown', 'vim', 'vimdoc' },
        -- Autoinstall languages that are not installed
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      }

      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see :help nvim-treesitter-incremental-selection-mod
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    end,
  },

  -- The following two comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- put them in the right spots if you want.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for kickstart
  --
  --  Here are some example plugins that I've included in the kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  --
  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --    For additional information see: :help lazy.nvim-lazy.nvim-structuring-your-plugins
  -- { import = 'custom.plugins' },
}
--]]
