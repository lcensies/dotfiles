local M = {}

-- In order to disable a default keymap, use
M.disabled = {
  n = {
    -- Variable info
    ["<S-k>"] = "",
    -- Rename
    ["<leader>ra"] = "",
    ["<leader>q"] = "",
    -- Marks are replaced with harpoon marks
    ["<leader>ma"] = "",
    -- switch between windows
    -- Mappings are delegated to the tmux-vim-navigator
    -- TODO: refactor plugin config
    ["<C-h>"] = "",
    ["<C-l>"] = "",
    ["<C-j>"] = "",
    ["<C-k>"] = "",
  },
}

M.telescope = {
  plugin = true,
  n = {
    ["<leader>fm"] = {
      "<cmd> Telescope harpoon marks <CR>",
      "Find Harpoon marks",
    },
  },
  v = {
    ["<leader>fs"] = {
      "<cmd> lua require'telescope.builtin'.grep_string({search = vim.fn.expand('<cword>')}) <CR>",
      "Find selection",
    },
  },
}

-- Telescope harpoon marks
M.harpoon = {
  plugin = true,
  n = {
    ["<leader>a"] = {
      '<cmd> lua require("harpoon.mark").add_file() <CR>',
      "Harpoon add file",
    },
    -- fr aka find recent
    ["<leader>fr"] = {
      '<cmd> lua require("harpoon.ui").toggle_quick_menu() <CR>',
      "Harpoon toggle menu",
    },
  },
}

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = {
      "<cmd> DapToggleBreakpoint <CR>",
      "Add breakpoint at line",
    },
    ["<leader>dr"] = {
      "<cmd> DapContinue <CR>",
      "Start or continue the debugger",
    },
    ["<leader>dus"] = {
      function()
        local widgets = require "dap.ui.widgets"
        local sidebar = widgets.sidebar(widgets.scopes)
        sidebar.open()
      end,
      "Open debugging sidebar",
    },
  },
}

M.dap_go = {
  plugin = true,
  n = {
    ["<leader>dgt"] = {
      function()
        require("dap-go").debug_test()
      end,
      "Debug go test",
    },
    ["<leader>dgl"] = {
      function()
        require("dap-go").debug_last()
      end,
      "Debug go last test",
    },
  },
}

M.nvterm = {
  plugin = true,

  t = {

    ["<A-s>"] = {
      function()
        require("nvterm.terminal").toggle "horizontal"
      end,
      "Toggle horizontal term",
    },
  },

  n = {
    ["<A-s>"] = {
      function()
        require("nvterm.terminal").toggle "horizontal"
      end,
      "Toggle horizontal term",
    },
  },
}

M.tabufline = {
  plugin = true,

  n = {
    -- cycle through buffers
    ["<S-k>"] = {
      function()
        require("nvchad.tabufline").tabuflineNext()
      end,
      "Goto next buffer",
    },

    ["<S-j>"] = {
      function()
        require("nvchad.tabufline").tabuflinePrev()
      end,
      "Goto prev buffer",
    },
  },
}

M.splits = {
  n = {

    ["<leader>sc"] = { "<cmd> split <CR>" },
    ["<leader>sv"] = { "<cmd> vsplit <CR>" },
  },
}

M.crates = {
  plugin = true,
  n = {
    ["<leader>rcu"] = {
      function()
        require("crates").upgrade_all_crates()
      end,
      "update crates",
    },
  },
}

M.trouble = {
  plugin = true,
  n = {
    ["<leader>T"] = {
      function()
        require("trouble").toggle "document_diagnostics"
      end,
    },
  },
}

M.git_worktree = {
  plugin = true,
    n = {
    ["<leader>gwa"] = {
      "<cmd> lua require('telescope').extensions.git_worktree.create_git_worktree() <CR>",
      "Git worktree add",
    },
    ["<leader>gws"] = {
      "<cmd> lua require('telescope').extensions.git_worktree.git_worktrees() <CR>",
      "Git workTree switch"
    }
  },

}
return M
