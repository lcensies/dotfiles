require "core"

-- Silence nvim-lspconfig deprecation warning (use vim.lsp.config) until config is migrated
do
  local orig = vim.deprecate
  vim.deprecate = function(name, alternative, version, plugin, ...)
    if plugin == "nvim-lspconfig" then
      return
    end
    return orig(name, alternative, version, plugin, ...)
  end
end

-- Use new LSP API so plugins calling get_active_clients() don't trigger deprecation
if vim.fn.has("nvim-0.11") == 1 and vim.lsp.get_clients then
  vim.lsp.get_active_clients = vim.lsp.get_clients
end

local custom_init_path = vim.api.nvim_get_runtime_file("lua/custom/init.lua", false)[0]

if custom_init_path then
  dofile(custom_init_path)
end

require("core.utils").load_mappings()

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- bootstrap lazy.nvim!
if not vim.loop.fs_stat(lazypath) then
  require("core.bootstrap").gen_chadrc_template()
  require("core.bootstrap").lazy(lazypath)
end

dofile(vim.g.base46_cache .. "defaults")
vim.opt.rtp:prepend(lazypath)
require "plugins"

-- Patch NvChad statusline to use vim.lsp.get_clients() (avoids :checkhealth vim.deprecated warning)
vim.schedule(function()
  local ok, minimal = pcall(require, "nvchad.statusline.minimal")
  if ok and minimal and minimal.LSP_status then
    local get_clients = vim.lsp.get_clients
    if get_clients then
      local stbufnr = function()
        return vim.api.nvim_win_get_buf(vim.g.statusline_winid or vim.api.nvim_get_current_win())
      end
      minimal.LSP_status = function()
        if not rawget(vim, "lsp") then
          return ""
        end
        for _, client in ipairs(get_clients({ bufnr = stbufnr() }) or {}) do
          if client.name ~= "null-ls" then
            if vim.o.columns > 100 then
              return "%#St_lsp_sep#%#St_lsp_bg#  %#St_lsp_txt# " .. client.name .. " %#St_sep_r# %#ST_EmptySpace#"
            end
            return "  LSP "
          end
        end
        return ""
      end
    end
  end
end)

-- TODO: move to separate config
vim.g.dap_virtual_text = true
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.conceallevel = 1

-- Figure out the system Python for Neovim.
-- if vim.fn.exists "$VIRTUAL_ENV" == 1 then
--   vim.g.python3_host_prog = vim.fn.substitute(vim.fn.system "which -a python3 | head -n2 | tail -n1", "\n", "", "g")
-- else
--   vim.g.python3_host_prog = vim.fn.substitute(vim.fn.system "which python3", "\n", "", "g")
-- end
