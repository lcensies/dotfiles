require "core"

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
