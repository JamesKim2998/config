-- Custom markdown list continuation for checkmate rendered symbols and blockquotes
-- Keymaps: o/O (new line), <leader>tt (toggle), <CR> (insert mode continuation)
return {
	name = "markdown-lists",
	dir = ".",
	ft = "markdown",
	dependencies = { "bullets-vim/bullets.vim", "bngarren/checkmate.nvim" },
	config = function()
		-- Checkmate rendered markers (□=unchecked, ✔=checked, others=partial states)
		local markers = { "□", "○", "●", "◐", "◑", "✓", "✗", "✔" }

		-- Find first rendered marker in line (by position, not list order)
		local function find_marker(line)
			local first_pos, first_m = nil, nil
			for _, m in ipairs(markers) do
				local pos = line:find(m, 1, true)
				if pos and (not first_pos or pos < first_pos) then
					first_pos, first_m = pos, m
				end
			end
			return first_m
		end

		-- Get prefix for new checkbox/blockquote line
		local function get_prefix()
			local line = vim.api.nvim_get_current_line()
			local bq = line:match("^(%s*>+%s*)") -- blockquote
			if bq then return bq end
			local cb = line:match("^(%s*[-*]%s*)%[.%]") -- raw checkbox
			if cb then return cb .. "[ ] " end
			if find_marker(line) then -- rendered checkbox
				return (line:match("^(%s*)") or "") .. "- [ ] "
			end
		end

		-- Trigger checkmate to convert markdown -> unicode
		local function checkmate_convert()
			pcall(require("checkmate.api").process_buffer, 0, "full", "markdown-lists")
		end

		-- Insert line with prefix and trigger checkmate conversion
		local function insert_line(row, prefix)
			vim.api.nvim_buf_set_lines(0, row, row, false, { prefix })
			vim.api.nvim_win_set_cursor(0, { row + 1, #prefix })
			checkmate_convert()
		end

		-- Feedkeys helper
		local function feedkeys(keys)
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
		end

		-- o/O: new line with prefix
		local function newline(below)
			local prefix = get_prefix()
			if prefix then
				local row = vim.api.nvim_win_get_cursor(0)[1]
				insert_line(below and row or row - 1, prefix)
				vim.cmd("startinsert!")
			elseif below then
				feedkeys("<Plug>(bullets-newline)")
			else
				vim.cmd("normal! O")
			end
		end

		-- Toggle: [ ]<->[x], □->[x], others->[ ]
		local function toggle()
			local line = vim.api.nvim_get_current_line()
			local new_line, n = line:gsub("%[ %]", "[x]", 1)
			if n == 0 then new_line, n = line:gsub("%[x%]", "[ ]", 1) end
			if n == 0 then
				local m = find_marker(line)
				if m then new_line = line:gsub(m, m == "□" and "[x]" or "[ ]", 1) end
			end
			if new_line ~= line then
				local row = vim.api.nvim_win_get_cursor(0)[1]
				vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
				checkmate_convert()
			end
		end

		-- <CR> in insert mode
		local function cr_handler()
			local prefix = get_prefix()
			if prefix then
				vim.cmd("stopinsert")
				vim.schedule(function()
					insert_line(vim.api.nvim_win_get_cursor(0)[1], prefix)
					vim.cmd("startinsert!")
				end)
			else
				feedkeys("<Plug>(bullets-newline)")
			end
		end

		-- Set buffer-local keymaps
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function()
				local opts = { buffer = true }
				vim.keymap.set("n", "o", function() newline(true) end, opts)
				vim.keymap.set("n", "O", function() newline(false) end, opts)
				vim.keymap.set("n", "<leader>tt", toggle, opts)
				vim.keymap.set("i", "<CR>", cr_handler, opts)
			end,
		})
	end,
}
