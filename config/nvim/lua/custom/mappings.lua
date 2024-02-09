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

    -- Terminal toggling with alt is impossible due to the
    -- toggle
    ["<A-h>"] = "",
    ["<A-v>"] = "",

    ["<leader>th"] = "",
  },
  v = {
    ["J"] = "",
    ["K"] = "",
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
    ["<leader>du"] = {
      "<cmd> lua require'dap'.up() <CR>",
      "Debugger go to frame up",
    },
    ["<leader>dd"] = {
      "<cmd> lua require'dap'.down() <CR>",
      "Debugger go to frame down",
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

M.dap_python = {
  plugin = true,
  n = {
    ["<leader>dpr"] = {
      function()
        require("dap-python").test_method()
      end,
    },
  },
}

M.nvterm = {
  plugin = true,

  -- Causes delay after pressing space in terminal
  -- t = {
  --
  --   ["<leader>th"] = {
  --     function()
  --       require("nvterm.terminal").toggle "horizontal"
  --     end,
  --     "Toggle horizontal term",
  --   },
  --   ["<leader>tv"] = {
  --     function()
  --       require("nvterm.terminal").toggle "vertical"
  --     end,
  --     "Toggle vertical term",
  --   },
  -- },

  n = {
    ["<leader>th"] = {
      function()
        require("nvterm.terminal").toggle "horizontal"
      end,
      "Toggle horizontal term",
    },
    ["<leader>tv"] = {
      function()
        require("nvterm.terminal").toggle "vertical"
      end,
      "Toggle vertical term",
    },
  },
}

-- M.tabufline = {
--   plugin = true,
--
--   n = {
--     -- cycle through buffers
--     ["<S-k>"] = {
--       function()
--         require("nvchad.tabufline").tabuflineNext()
--       end,
--       "Goto next buffer",
--     },
--
--     ["<S-j>"] = {
--       function()
--         require("nvchad.tabufline").tabuflinePrev()
--       end,
--       "Goto prev buffer",
--     },
--   },
-- }

M.splits = {
  n = {

    ["<leader>sc"] = { "<cmd> split <CR>" },
    ["<leader>sv"] = { "<cmd> vsplit <CR>" },
  },
}

M.yanks = {
  n = {
    ["<leader>yf"] = { "<cmd> :let @+=expand('%:t')<CR>", "Yank current filename" },
    ["<leader>ya"] = { '[["+y]]', "Yank all content" },
  },
}

M.motions = {
  i = {
    ["<C-c>"] = { "<Esc>", "Exit insert mode with Ctrl+c" },
  },
  v = {
    ["J"] = { ":m '>+1<CR>gv=gv", "Move selection up" },
    ["K"] = { ":m '<-2<CR>gv=gv", "Move selection down" },
    ["H"] = { "^", "Go to the beginning of the line" },
    ["L"] = { "$", "Go to the end of the line" },
  },
  n = {
    -- TODO: add shortcuts for joining lines
    ["<C-d>"] = { "<C-d>zz", "Page down and center cursor" },
    ["<C-u>"] = { "<C-u>zz", "Page up and center cursor" },
    ["H"] = { "^", "Go to the beginning of the line" },
    ["L"] = { "$", "Go to the end of the line" },
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
      "Git workTree switch",
    },
  },
}
return M
