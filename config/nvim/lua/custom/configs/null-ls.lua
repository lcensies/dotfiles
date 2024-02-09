local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require "null-ls"

local opts = {
  sources = {
    -- null_ls.builtins.formatting.clang_format,

    -- null_ls.builtins.formatting.stylua,
    null_ls.builtins.diagnostics.luacheck,
    -- For some reason, conform + jq is not working
    null_ls.builtins.formatting.jq,
    -- Configuration of yamlfix ig broken with yamlfix and null-ls, so I
    -- switched to conform for formatters
    -- null_ls.builtins.formatting.yamlfmt,
    -- null_ls.builtins.formatting.yamlfix,

    -- Go
    -- null_ls.builtins.formatting.gofumpt,
    -- null_ls.builtins.formatting.goimports_reviser,
    -- null_ls.builtins.formatting.golines,

    -- Python
    -- null_ls.builtins.formatting.black,
    null_ls.builtins.diagnostics.mypy,
    null_ls.builtins.diagnostics.ruff,

    -- Markdown
    -- null_ls.builtins.diagnostics.markdownlint,
  },
  -- on_attach = function(client, bufnr)
  --   if client.supports_method "textDocument/formatting" then
  --     vim.api.nvim_clear_autocmds {
  --       group = augroup,
  --       buffer = bufnr,
  --     }
  --     vim.api.nvim_create_autocmd("BufWritePre", {
  --       group = augroup,
  --       buffer = bufnr,
  --       callback = function()
  --         vim.lsp.buf.format { bufnr = bufnr }
  --       end,
  --     })
  --   end
  -- end,
}

return opts
