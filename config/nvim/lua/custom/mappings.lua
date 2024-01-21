local M = {}

-- In order to disable a default keymap, use
M.disabled = {
  n = {
    -- Variable info
    ["<S-k>"] = "",
    -- Rename
    ["<leader>ra"] = "",
  },
}

M.harpoon = {
  plugin = true,
  n = {
    ["<leader><S-h>a"] = {
      '<cmd> lua require("harpoon.mark").add_file()',
    },
    ["<leader><S-h>t"] = {
      'lua require("harpoon.ui").toggle_quick_menu()',
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

return M
