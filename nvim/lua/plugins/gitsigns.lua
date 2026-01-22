-- https://github.com/lewis6991/gitsigns.nvim
return {
	"lewis6991/gitsigns.nvim",
	event = "BufReadPost",
	opts = {
		on_attach = function(bufnr)
			local gs = require("gitsigns")
			local map = function(mode, l, r, desc)
				vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
			end
			-- Navigation
			map("n", "]h", gs.next_hunk, "Next hunk")
			map("n", "[h", gs.prev_hunk, "Prev hunk")
			-- Stage/unstage
			map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
			map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
			map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage lines")
			map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset lines")
			map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
			map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
			map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
			-- Preview/blame
			map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
			map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
		end,
	},
}
