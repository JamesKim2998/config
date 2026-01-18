-- Markdown extras (complements bullets.vim and render-markdown.nvim)
-- Keymaps:
--   <leader>tt  toggle checkbox [ ] <-> [x]
--   o/O         blockquote continuation (> prefix)
--   <CR>        blockquote continuation in insert mode
-- Features:
--   Strikethrough on checked [x] items (text only, not checkbox)
return {
	name = "markdown-lists",
	dir = ".",
	ft = "markdown",
	config = function()
		local ns = vim.api.nvim_create_namespace("markdown-checkbox-strikethrough")
		vim.api.nvim_set_hl(0, "CheckboxStrikethrough", { strikethrough = true })

		local function apply_strikethrough(buf)
			vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
			for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
				local prefix_end = line:match("^%s*[-*+]%s*%[[xX]%]%s*()")
					or line:match("^%s*%d+[.)]%s*%[[xX]%]%s*()")
				if prefix_end and prefix_end <= #line then
					vim.api.nvim_buf_set_extmark(buf, ns, i - 1, prefix_end - 1, {
						end_col = #line,
						hl_group = "CheckboxStrikethrough",
					})
				end
			end
		end

		local function toggle_checkbox()
			local line = vim.api.nvim_get_current_line()
			local new_line = line:match("%[ %]") and line:gsub("%[ %]", "[x]", 1)
				or line:match("%[[xX]%]") and line:gsub("%[[xX]%]", "[ ]", 1)
			if new_line then
				local row = vim.api.nvim_win_get_cursor(0)[1]
				vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
				apply_strikethrough(0)
			end
		end

		local function blockquote_newline(below)
			local prefix = vim.api.nvim_get_current_line():match("^(%s*>+%s*)")
			if not prefix then
				return false
			end
			local row = vim.api.nvim_win_get_cursor(0)[1]
			local target = below and row or row - 1
			vim.api.nvim_buf_set_lines(0, target, target, false, { prefix })
			vim.api.nvim_win_set_cursor(0, { below and row + 1 or row, #prefix })
			vim.cmd("startinsert!")
			return true
		end

		local function handle_cr()
			local prefix = vim.api.nvim_get_current_line():match("^(%s*>+%s*)")
			if prefix then
				local row = vim.api.nvim_win_get_cursor(0)[1]
				vim.schedule(function()
					vim.api.nvim_buf_set_lines(0, row, row, false, { prefix })
					vim.api.nvim_win_set_cursor(0, { row + 1, #prefix })
				end)
				return ""
			end
			return vim.api.nvim_replace_termcodes("<Plug>(bullets-newline)", true, false, true)
		end

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function(ev)
				local o = { buffer = true }
				vim.keymap.set("n", "<leader>tt", toggle_checkbox, o)
				vim.keymap.set("n", "o", function() if not blockquote_newline(true) then vim.cmd("normal! o") end end, o)
				vim.keymap.set("n", "O", function() if not blockquote_newline(false) then vim.cmd("normal! O") end end, o)
				vim.keymap.set("i", "<CR>", handle_cr, { buffer = true, expr = true })
				apply_strikethrough(ev.buf)
				vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
					buffer = ev.buf,
					callback = function() apply_strikethrough(ev.buf) end,
				})
			end,
		})
	end,
}
