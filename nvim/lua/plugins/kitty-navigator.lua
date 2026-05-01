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

		-- Normal & insert mode: navigate vim splits (KittyNavigate* falls through
		-- to the neighboring kitty window at the edge), or focus kitty directly
		-- if a float is visible (otherwise the float would eat the navigation).
		-- wincmd from an insert-mode callback changes window without leaving insert.
		local function nav(cmd, kitty_dir)
			return function()
				if any_float_visible() then
					kitty_focus(kitty_dir)
					return
				end
				vim.cmd(cmd)
			end
		end
		for _, mode in ipairs({ "n", "i" }) do
			vim.keymap.set(mode, "<C-h>", nav("KittyNavigateLeft", "left"))
			vim.keymap.set(mode, "<C-j>", nav("KittyNavigateDown", "bottom"))
			vim.keymap.set(mode, "<C-k>", nav("KittyNavigateUp", "top"))
			vim.keymap.set(mode, "<C-l>", nav("KittyNavigateRight", "right"))
		end

		-- Cmdline mode: only intercept when a float is visible; otherwise preserve
		-- defaults (<C-h> = backspace etc.) so editing the command line keeps working.
		local function cmdline_nav(kitty_dir, key)
			return function()
				if any_float_visible() then
					kitty_focus(kitty_dir)
					return ""
				end
				return vim.api.nvim_replace_termcodes(key, true, false, true)
			end
		end
		vim.keymap.set("c", "<C-h>", cmdline_nav("left", "<C-h>"), { expr = true })
		vim.keymap.set("c", "<C-j>", cmdline_nav("bottom", "<C-j>"), { expr = true })
		vim.keymap.set("c", "<C-k>", cmdline_nav("top", "<C-k>"), { expr = true })
		vim.keymap.set("c", "<C-l>", cmdline_nav("right", "<C-l>"), { expr = true })
	end,
}
