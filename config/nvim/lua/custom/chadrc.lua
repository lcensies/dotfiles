---@type ChadrcConfig
local M = {}
M.ui = {
  theme = "gruvchad",

  statusline = {
    theme = "minimal", -- default/vscode/vscode_colored/minimal

    -- default/round/block/arrow (separators work only for "default" statusline theme;
    -- round and block will work for the minimal theme only)
    -- separator_style = "default",
    -- overriden_modules = nil,
  },

  transparency = true,
}

M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"
return M
