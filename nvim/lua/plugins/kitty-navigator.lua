-- https://github.com/knubie/vim-kitty-navigator
-- When any float is visible (Snacks notifier, Lazy, Noice, etc.), bypass vim
-- pane navigation and focus the neighboring kitty window instead. Without this,
-- C-hjkl moves focus out of the float into a vim split, with no way to return.
return {
	"knubie/vim-kitty-navigator",
	init = function()
		vim.g.kitty_navigator_no_mappings = 1
	end,
	config = function()
		local function kitty_focus(dir)
			vim.fn.system("kitty @ focus-window --match neighbor:" .. dir)
		end

		local function any_float_visible()
			for _, w in ipairs(vim.api.nvim_list_wins()) do
				if vim.api.nvim_win_get_config(w).relative ~= "" then
					return true
				end
			end
			return false
		end

		-- Normal mode: navigate vim splits, or kitty if any float is visible
		local function nav(cmd, kitty_dir)
			return function()
				if any_float_visible() then
					kitty_focus(kitty_dir)
					return
				end
				vim.cmd(cmd)
			end
		end
		vim.keymap.set("n", "<C-h>", nav("KittyNavigateLeft", "left"))
		vim.keymap.set("n", "<C-j>", nav("KittyNavigateDown", "bottom"))
		vim.keymap.set("n", "<C-k>", nav("KittyNavigateUp", "top"))
		vim.keymap.set("n", "<C-l>", nav("KittyNavigateRight", "right"))

		-- Insert/cmdline mode: same rule, but preserve default keys when no float
		local function modal_nav(kitty_dir, key)
			return function()
				if any_float_visible() then
					kitty_focus(kitty_dir)
					return ""
				end
				return vim.api.nvim_replace_termcodes(key, true, false, true)
			end
		end
		for _, mode in ipairs({ "i", "c" }) do
			vim.keymap.set(mode, "<C-h>", modal_nav("left", "<C-h>"), { expr = true })
			vim.keymap.set(mode, "<C-j>", modal_nav("bottom", "<C-j>"), { expr = true })
			vim.keymap.set(mode, "<C-k>", modal_nav("top", "<C-k>"), { expr = true })
			vim.keymap.set(mode, "<C-l>", modal_nav("right", "<C-l>"), { expr = true })
		end
	end,
}
