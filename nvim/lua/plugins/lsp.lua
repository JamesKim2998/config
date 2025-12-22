-- https://github.com/mason-org/mason-lspconfig.nvim
-- LSP support: mason (installer) + lspconfig (configuration)
-- Run :Mason to install language servers (e.g., pyright, ts_ls, gopls)
-- Auto-installed: lua_ls
return {
	"mason-org/mason-lspconfig.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
		"neovim/nvim-lspconfig",
	},
	opts = {
		-- Servers to auto-install
		ensure_installed = {
			"lua_ls",
		},
	},
	config = function(_, opts)
		require("mason-lspconfig").setup(opts)

		-- LSP keybindings (set when LSP attaches to buffer)
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local bufnr = args.buf
				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end

				map("n", "gd", vim.lsp.buf.definition, "Go to definition")
				map("n", "gr", vim.lsp.buf.references, "Go to references")
				map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
				map("n", "gI", vim.lsp.buf.implementation, "Go to implementation")
				map("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")
				map("n", "K", vim.lsp.buf.hover, "Hover documentation")
				map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
				map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
				map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
				map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
			end,
		})
	end,
}
