return {
  -- the plugin was renamed from “null-ls” → “none-ls” in 2024
  "nvimtools/none-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },   -- lazy-load on first file
  dependencies = { "nvim-lua/plenary.nvim" }, -- hard requirement:contentReference[oaicite:0]{index=0}
  config = function()
    local null_ls = require("null-ls")
    local formatting  = null_ls.builtins.formatting
    local diagnostics = null_ls.builtins.diagnostics
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

    null_ls.setup({
      sources = {
        formatting.stylua,          -- Lua
        formatting.prettier,        -- JS/TS/…  (needs prettier on PATH)
        diagnostics.eslint_d,       -- JS/TS lint (fast daemon)
      },
      on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr })
            end,
          })
        end
      end,
    })
  end,
}
