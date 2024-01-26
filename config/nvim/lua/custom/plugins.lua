local cmp = require "cmp"

local plugins = {
  {
    "rcarriga/nvim-dap-ui",
    event = "VeryLazy",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      handlers = {},
    },
  },
  {
    "mfussenegger/nvim-dap",
    config = function(_, _)
      require("core.utils").load_mappings "dap"
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = "VeryLazy",
    opts = function()
      return require "custom.configs.null-ls"
    end,
  },
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = "mfussenegger/nvim-dap",
    config = function(_, opts)
      require("dap-go").setup(opts)
      require("core.utils").load_mappings "dap_go"
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

        "yamlfix",
        -- "yamlfmt",

        "gopls",
        "goimports-reviser",
        "golines",
        "gofumpt",

        "rust-analyzer",
      },
    },
  },
  {
    "ThePrimeagen/harpoon",
    event = "VeryLazy",
    config = function(_, opts)
      require("core.utils").load_mappings "harpoon"
    end,
  },
  {
    -- Required by harpoon
    "nvim-lua/plenary.nvim",
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
    "theHamsta/nvim-dap-virtual-text",
    lazy = false,
    config = function(_, opts)
      require("nvim-dap-virtual-text").setup()
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
      extensions_list = { "harpoon" },
    },
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    -- cmd = { "ConformInfo" },
    opts = {
      lsp_fallback = true,
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        go = { "gofumpt", "goimports-reviser", "golines" },
        cpp = { "clang_format" },
        c = { "clang_format" },
        yaml = { "yamlfix" },
        sh = { "shfmt" },
      },
      formatters = {
        yamlfix = {
          env = {
            YAMLFIX_SEQUENCE_STYLE = "block_style",
          },
        },
      },
      init = function()
        -- If you want the formatexpr, here is the place to set it
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      end,
    },
    -- config = function(_, opts)
    --   require("conform").setup({
    --     format_on_save = {
    --       -- These options will be passed to conform.format()
    --       timeout_ms = 500,
    --       lsp_fallback = true,
    --     },
    --     formatters_by_ft = {
    --       lua = { "stylua" },
    --       -- Conform will run multiple formatters sequentially
    --       python = { "isort", "black" },
    --       -- Use a sub-list to run only the first available formatter
    --       yaml = { "yamlfix "},
    --
    --       go = { "gofumpt" },
    --
    --       c = { "clang_format" },
    --       cpp = { "clang_format "},
    --     },
    --   })
    -- end,
  },
}
return plugins
