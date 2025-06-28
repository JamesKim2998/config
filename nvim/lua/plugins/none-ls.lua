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
			-- https://github.com/nvimtools/none-ls.nvim/wiki/Formatting-on-save#code
			on_attach = function(client, bufnr)
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.formatting_sync()
						end,
					})
				end
			end,
		})
	end,
}
