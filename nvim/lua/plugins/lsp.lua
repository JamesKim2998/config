-- https://github.com/mason-org/mason-lspconfig.nvim
-- LSP support: mason (installer) + lspconfig (configuration)
-- Run :Mason to install language servers
return {
	"mason-org/mason-lspconfig.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
		"neovim/nvim-lspconfig",
	},
	opts = {
		ensure_installed = { "bashls", "lua_ls", "ts_ls", "csharp_ls", "marksman" },
		automatic_installation = true,
		-- automatic_enable = true (default) - auto-enables installed servers
	},
	config = function(_, opts)
		-- Configure LSP servers BEFORE mason-lspconfig.setup() for automatic_enable to work

		-- csharp_ls for C#/.NET/Unity projects - find .sln file
		vim.lsp.config("csharp_ls", {
			root_dir = function(bufnr, on_dir)
				local fname = vim.api.nvim_buf_get_name(bufnr)
				-- Find .sln file by traversing up
				local sln = vim.fs.find(function(name)
					return name:match("%.sln$")
				end, { path = fname, upward = true, type = "file" })[1]
				if sln then
					on_dir(vim.fs.dirname(sln))
				end
			end,
		})

		-- TypeScript inlay hints (parameter names, return types, etc.)
		vim.lsp.config("ts_ls", {
			settings = {
				typescript = {
					inlayHints = {
						includeInlayParameterNameHints = "literals", -- only show hints for literal args, not variables
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = false, -- redundant with explicit annotations
						includeInlayVariableTypeHintsWhenTypeMatchesName = false,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
				javascript = {
					inlayHints = {
						includeInlayParameterNameHints = "literals", -- only show hints for literal args, not variables
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = false, -- redundant with explicit annotations
						includeInlayVariableTypeHintsWhenTypeMatchesName = false,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
			},
		})

		-- Enable mason-lspconfig after configuring servers
		require("mason-lspconfig").setup(opts)

		-- Keymaps on LSP attach
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local bufnr = args.buf
				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end

				-- Enable inlay hints by default
				vim.lsp.inlay_hint.enable(true)

				-- gd, gr, gI, gy mapped in trouble.nvim
				map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
				map("n", "K", vim.lsp.buf.hover, "Hover documentation")
				-- <leader>rn mapped in inc-rename.nvim
				map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
				map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
				map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
				map("n", "<leader>th", function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
				end, "Toggle inlay hints")
			end,
		})
	end,
}
