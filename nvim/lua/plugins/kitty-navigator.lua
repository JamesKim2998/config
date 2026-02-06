-- https://github.com/knubie/vim-kitty-navigator
-- No-op in floating windows to prevent stuck focus
return {
	"knubie/vim-kitty-navigator",
	init = function()
		vim.g.kitty_navigator_no_mappings = 1
	end,
	config = function()
		local function nav(cmd)
			return function()
				if vim.api.nvim_win_get_config(0).relative ~= "" then return end
				vim.cmd(cmd)
			end
		end
		vim.keymap.set("n", "<C-h>", nav("KittyNavigateLeft"))
		vim.keymap.set("n", "<C-j>", nav("KittyNavigateDown"))
		vim.keymap.set("n", "<C-k>", nav("KittyNavigateUp"))
		vim.keymap.set("n", "<C-l>", nav("KittyNavigateRight"))
	end,
}
