return {
	"nvimtools/none-ls.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		-- allows you to easily manage external editor tooling such as LSP servers, DAP servers, linters, and formatters through a single interface.
		-- https://github.com/mason-org/mason.nvim
		"williamboman/mason.nvim",
		-- The test suite includes unit and integration tests and depends on plenary.nvim.
		-- https://github.com/nvim-lua/plenary.nvim
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local null_ls = require("null-ls")
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

		null_ls.setup({
			sources = {
				null_ls.builtins.completion.spell,
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.diagnostics.selene, -- https://github.com/Kampfkarren/selene
			},
			diagnostics_format = "[#{c}] #{m} (#{s})", -- optional prettier format
			on_attach = function(client, bufnr)
				-- keymaps for diagnostics
				local map = function(lhs, rhs, desc)
					vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
				end
				map("<leader>e", vim.diagnostic.open_float, "Line diagnostics")
				map("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
				map("]d", vim.diagnostic.goto_next, "Next diagnostic")
				map("<leader>q", function()
					vim.diagnostic.setloclist()
				end, "Buffer diagnostics → loclist")
				-- format on save
				-- https://github.com/nvimtools/none-ls.nvim/wiki/Formatting-on-save#code
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
