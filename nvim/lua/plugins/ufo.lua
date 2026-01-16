-- https://github.com/kevinhwang91/nvim-ufo
return {
	"kevinhwang91/nvim-ufo",
	dependencies = "kevinhwang91/promise-async",
	event = "BufReadPost", -- Load when a real file is opened
	init = function()
		vim.o.foldcolumn = "0" -- hide fold column for cleaner look
		vim.o.foldlevel = 99 -- start with all folds open
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true
	end,
	keys = {
		{
			"zR",
			function()
				require("ufo").openAllFolds()
			end,
			desc = "UFO: open all folds",
		},
		{
			"zM",
			function()
				require("ufo").closeAllFolds()
			end,
			desc = "UFO: close all folds",
		},
	},
	config = function()
		-- Compact fold text: shows first line + line count
		-- https://github.com/kevinhwang91/nvim-ufo#customize-fold-text
		local handler = function(virtText, lnum, endLnum, width, truncate)
			local newVirtText = {}
			local suffix = (" 󰁂 %d "):format(endLnum - lnum)
			local sufWidth = vim.fn.strdisplaywidth(suffix)
			local targetWidth = width - sufWidth
			local curWidth = 0
			for _, chunk in ipairs(virtText) do
				local chunkText = chunk[1]
				local chunkWidth = vim.fn.strdisplaywidth(chunkText)
				if targetWidth > curWidth + chunkWidth then
					table.insert(newVirtText, chunk)
				else
					chunkText = truncate(chunkText, targetWidth - curWidth)
					local hlGroup = chunk[2]
					table.insert(newVirtText, { chunkText, hlGroup })
					chunkWidth = vim.fn.strdisplaywidth(chunkText)
					if curWidth + chunkWidth < targetWidth then
						suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
					end
					break
				end
				curWidth = curWidth + chunkWidth
			end
			table.insert(newVirtText, { suffix, "MoreMsg" })
			return newVirtText
		end

		require("ufo").setup({
			provider_selector = function(_, _)
				return { "lsp", "indent" } -- LSP needed for 'imports' kind
			end,
			close_fold_kinds_for_ft = {
				default = { "imports" },
			},
			fold_virt_text_handler = handler,
		})
	end,
}
