-- https://github.com/mfussenegger/nvim-lint
-- Linters: sh→shellcheck, lua→selene
-- Triggers on BufEnter and BufWritePost (not InsertLeave to avoid lag)
return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		lint.linters_by_ft = {
			sh = { "shellcheck" },
			lua = { "selene" },
		}

		-- Force bash dialect so shellcheck accepts .command files
		table.insert(lint.linters.shellcheck.args, 1, "--shell=bash")

		-- Run linting automatically on events
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
