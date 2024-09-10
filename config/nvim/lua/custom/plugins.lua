local cmp = require "cmp"

local plugins = {
  {
    "ray-x/go.nvim",
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()
      -- require("core.utils").load_mappings "go"
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  },

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    -- event = { "BufReadPre", "BufNewFile" },
    -- event = { "VeryLazy" },
    -- cmd = { "ConformInfo" },
    opts = {
      -- lsp_fallback = true,
      lsp_fallback = true,
      format_on_save = { lsp_fallback = true },
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        go = { "gofumpt", "goimports-reviser", "golines" },
        cpp = { "clang_format" },
        c = { "clang_format" },
        yaml = { "yamlfix" },
        sh = { "shfmt" },
        json = { "jq " },
        -- markdown = { "mdformat" },
      },
      formatters = {
        yamlfix = {
          env = {
            YAMLFIX_SEQUENCE_STYLE = "block_style",
          },
        },
      },
      -- init = function()
      --   -- If you want the formatexpr, here is the place to set it
      --   vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      -- end,
    },
  },
  {
    "nvimtools/none-ls.nvim",
    -- "jose-elias-alvarez/null-ls.nvim",
    event = "VeryLazy",
    opts = function()
      return require "custom.configs.null-ls"
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "clangd",
        "clang-format",
        "codelldb",
        -- Lua
        "lua-language-server",
        "stylua",
        "luacheck",

        -- "ansible-language-server",
        -- "ansible-lint",

        -- bash
        "shfmt",
        "bash-language-server",
        "shellcheck",

        "yamlfix",
        -- "yamlfmt",

        "gopls",
        "goimports-reviser",
        "golines",
        "gofumpt",

        "rust-analyzer",

        "jq",

        -- Python
        "pyright",
        "black",
        "mypy",
        "ruff",
        "debugpy",

        "mdformat",
        "markdownlint",
      },
    },
  },
  {
    "ThePrimeagen/harpoon",
    event = "VeryLazy",
    config = function(_, opts)
      require("core.utils").load_mappings "harpoon"
    end,
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "saecki/crates.nvim",
    ft = { "toml" },
    config = function(_, opts)
      local crates = require "crates"
      crates.setup(opts)
      require("cmp").setup.buffer {
        sources = { { name = "crates" } },
      }
      crates.show()
      require("core.utils").load_mappings "crates"
    end,
  },
  {
    "rust-lang/rust.vim",
    ft = "rust",
    init = function()
      -- TODO: consider other formatter
      vim.g.rustfmt_autosave = 1
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function()
      -- # TODO: move to mappings
      local M = require "plugins.configs.cmp"
      M.completion.completeopt = "menu,menuone,noselect"
      M.mapping["<CR>"] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Insert,
        select = false,
      }
      table.insert(M.sources, { name = "crates" })
      return M
    end,
  },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
  {
    "folke/trouble.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    config = function(_, opts)
      require("core.utils").load_mappings "trouble"
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      extensions_list = {
        "harpoon",
        -- 'fzy_native',
        "git_worktree",
      },
    },
    config = function(_, _)
      require("telescope").load_extension "fzy_native"
    end,
  },
  {
    "ThePrimeagen/git-worktree.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-lua/popup.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-telescope/telescope-fzy-native.nvim",
    },
    -- TODO: hook to update submodules on worktree checkout
    -- See https://www.youtube.com/watch?v=2uEqYw-N8uE
    config = function(_, _)
      require("core.utils").load_mappings "git_worktree"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",

        "json",
        "yaml",

        "c",
        "cpp",
        "rust",

        "go",

        "markdown",
        "markdown_inline",

        "vimdoc",
      },
    },
  },
  -- Seems OK,
  -- {
  --   "renerocksai/telekasten.nvim",
  --   dependencies = { "nvim-telescope/telescope.nvim" },
  --   event = "VeryLazy",
  --   config = function()
  --     require("telekasten").setup {
  --       home = vim.fn.expand "~/notes",
  --     }
  --   end,
  -- },
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    event = {
      -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
      -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
      "BufReadPre ~/notes/**.md",
      "BufNewFile ~/notes/**.md",
    },
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",

      -- see below for full list of optional dependencies 👇
    },
    opts = {
      new_notes_location = "current_dir",
      attachments = {
        img_folder = "attachments",
      },
      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d-%a",
        time_format = "%H:%M",
      },
      workspaces = {
        {
          name = "notes",
          path = "~/notes",
        },
        {
          name = "sysv",
          path = "~/Documents/sysv",
        },
        -- {
        --   name = "work",
        --   path = "~/vaults/work",
        -- },
      },

      daily_notes = {
        -- Optional, if you keep daily notes in a separate directory.
        folder = "daily",
        -- Optional, if you want to change the date format for the ID of daily notes.
        date_format = "%Y-%m-%d",
        -- Optional, if you want to change the date format of the default alias of daily notes.
        alias_format = "%B %-d, %Y",
        -- Optional, default tags to add to each new daily note created.
        default_tags = { "daily-notes" },
        -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
        template = "templates/Daily.md",
      },

      config = function(_, _)
        require("core.utils").load_mappings "obsidian"
      end,
      -- see below for full list of options 👇
    },
  },

  -- Might be useful, but currently using custom tools
  -- {
  --   "nvim-neotest/neotest",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "antoinemadec/FixCursorHold.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --     "nvim-neotest/neotest-python",
  --     -- Go adapter seems to be buggy
  --     "nvim-neotest/neotest-go",
  --   },
  --   event = "VeryLazy",
  --   config = function()
  --     require("core.utils").load_mappings "neotest"
  --     require("neotest").setup {
  --       adapters = {
  --         require "neotest-python" {
  --           -- Extra arguments for nvim-dap configuration
  --           -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
  --           dap = { justMyCode = false },
  --           -- Command line arguments for runner
  --           -- Can also be a function to return dynamic values
  --           args = { "--log-level", "DEBUG" },
  --           -- Runner to use. Will use pytest if available by default.
  --           -- Can be a function to return dynamic value.
  --           runner = "pytest",
  --           -- Custom python path for the runner.
  --           -- Can be a string or a list of strings.
  --           -- Can also be a function to return dynamic value.
  --           -- If not provided, the path will be inferred by checking for
  --           -- virtual envs in the local directory and for Pipenev/Poetry configs
  --           python = "./venv/bin/python",
  --           -- Returns if a given file path is a test file.
  --           -- NB: This function is called a lot so don't perform any heavy tasks within it.
  --           -- !!EXPERIMENTAL!! Enable shelling out to `pytest` to discover test
  --           -- instances for files containing a parametrize mark (default: false)
  --           pytest_discover_instances = true,
  --         },
  --         require "neotest-go",
  --       },
  --     }
  --   end,
  -- },

  -- {
  --   "shortcuts/no-neck-pain.nvim",
  --   config = function(_)
  --     require("core.utils").load_mappings "no_neck_pain"
  --     -- local autocmd = vim.api.nvim_create_autocmd -- Create autocommand
  --     -- autocmd("BufWritePre", {
  --     --   pattern = "",
  --     --   command = ":%s/\\s\\+$//e",
  --     -- })
  --   end,
  --
  --   event = "VeryLazy",
  -- },
  -- {
  --   "folke/zen-mode.nvim",
  --   conifg = function(_)
  --     require("core.utils").load_mappings "zen_mode"
  --   end,
  --
  --   event = "VeryLazy",
  --
  --   opts = {
  --     -- your configuration comes here
  --     -- or leave it empty to use the default settings
  --     -- refer to the configuration section below
  --   },
  -- },
  -- {
  --   "jackMort/ChatGPT.nvim",
  --   event = "VeryLazy",
  --   config = function()
  --     require("chatgpt").setup()
  --   end,
  --   dependencies = {
  --     "MunifTanjim/nui.nvim",
  --     "nvim-lua/plenary.nvim",
  --     "folke/trouble.nvim",
  --     "nvim-telescope/telescope.nvim",
  --   },
  -- },
  -- Well, I don't use debugger anyway
  -- {
  --   "leoluz/nvim-dap-go",
  --   ft = "go",
  --   dependencies = "mfussenegger/nvim-dap",
  --   config = function(_, opts)
  --     require("dap-go").setup(opts)
  --     require("core.utils").load_mappings "dap_go"
  --   end,
  -- },
  -- {
  --   "jay-babu/mason-nvim-dap.nvim",
  --   event = "VeryLazy",
  --   dependencies = {
  --     "williamboman/mason.nvim",
  --     "mfussenegger/nvim-dap",
  --   },
  --   opts = {
  --     handlers = {},
  --   },
  -- },
  -- {
  --   "mfussenegger/nvim-dap",
  --   config = function(_, _)
  --     require("core.utils").load_mappings "dap"
  --   end,
  -- },
  -- {
  --   "mfussenegger/nvim-dap-python",
  --   ft = "python",
  --   dependencies = {
  --     "mfussenegger/nvim-dap",
  --     "rcarriga/nvim-dap-ui",
  --   },
  --   config = function(_, opts)
  --     local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
  --     require("dap-python").setup(path)
  --     require("core.utils").load_mappings "dap_python"
  --   end,
  -- },

  -- {
  --   "rcarriga/nvim-dap-ui",
  --   event = "VeryLazy",
  --   dependencies = "mfussenegger/nvim-dap",
  --   config = function()
  --     local dap = require "dap"
  --     local dapui = require "dapui"
  --     dapui.setup()
  --     dap.listeners.after.event_initialized["dapui_config"] = function()
  --       dapui.open()
  --     end
  --     dap.listeners.before.event_terminated["dapui_config"] = function()
  --       dapui.close()
  --     end
  --     dap.listeners.before.event_exited["dapui_config"] = function()
  --       dapui.close()
  --     end
  --   end,
  -- },
  -- {
  --   "theHamsta/nvim-dap-virtual-text",
  --   lazy = false,
  --   config = function(_, opts)
  --     require("nvim-dap-virtual-text").setup()
  --   end,
  -- },
  {
    "lcensies/image.nvim",
    event = "VeryLazy",
    -- default config
    config = function(_, _)
      require("image").setup {
        backend = "kitty",
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
          },
          neorg = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { "norg" },
          },
          html = {
            enabled = false,
          },
          css = {
            enabled = false,
          },
        },
        max_width = nil,
        max_height = nil,
        max_width_window_percentage = nil,
        max_height_window_percentage = 50,
        window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
        editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
        tmux_show_only_in_active_window = true, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" }, -- render image files as images when opened
      }
    end,
  },
  -- {
  --   "edluffy/hologram.nvim",
  --   event = "VeryLazy",
  --   config = function(_, opts)
  --     require("hologram").setup {
  --       auto_display = true,
  --     }
  --   end,
  -- },
}
return plugins
