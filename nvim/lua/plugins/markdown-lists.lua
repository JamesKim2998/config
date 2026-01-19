-- Markdown list continuation and checkbox handling
-- Keymaps:
--   o/O         list continuation (checkbox, bullet, numbered, blockquote)
--   <CR>        list continuation in insert mode
--   <leader>tt  toggle checkbox [ ] <-> [x]
-- Features:
--   Auto-renumber: numbered lists renumber automatically on insert
--   Strikethrough on checked [x] items (text only, not checkbox)
--   Empty item <CR>: decreases indent (or removes prefix if no indent)
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

		-- Get continuation prefix for different line types
		-- Returns: prefix string or nil, and whether it's a list type

		-- Checkbox: "- [ ] item" -> "- [ ] "
		local function get_checkbox_prefix(line)
			local prefix = line:match("^(%s*[-*+]%s*)%[.%]")
			if prefix then return prefix .. "[ ] " end
			prefix = line:match("^(%s*%d+[.)]%s*)%[.%]")
			if prefix then return prefix .. "[ ] " end
			return nil
		end

		-- Bullet: "- item" -> "- "
		local function get_bullet_prefix(line)
			-- Don't match if it's a checkbox
			if line:match("^%s*[-*+]%s*%[.%]") then return nil end
			local prefix = line:match("^(%s*[-*+]%s*)")
			return prefix
		end

		-- Numbered: "1. item" -> "2. " (increment) or "0. " (decrement)
		local function get_numbered_prefix(line, increment)
			-- Don't match if it's a checkbox
			if line:match("^%s*%d+[.)]%s*%[.%]") then return nil end
			local indent, num, sep = line:match("^(%s*)(%d+)([.)])%s")
			if not num then return nil end
			local new_num = tonumber(num) + increment
			if new_num < 1 then new_num = 1 end
			return indent .. new_num .. sep .. " "
		end

		-- Check if line is a numbered list item (returns indent, sep or nil)
		local function is_numbered_line(line)
			if line:match("^%s*%d+[.)]%s*%[.%]") then return nil end -- checkbox
			local indent, sep = line:match("^(%s*)%d+([.)])%s")
			return indent, sep
		end

		-- Renumber consecutive numbered list items starting from row (0-indexed)
		-- starting_num is the number to assign to the first line
		local function renumber_below(row, starting_num, expected_indent, expected_sep)
			local lines = vim.api.nvim_buf_get_lines(0, row, -1, false)
			local changes = {}
			for i, line in ipairs(lines) do
				local indent, sep = is_numbered_line(line)
				if not indent or indent ~= expected_indent or sep ~= expected_sep then
					break
				end
				local expected_num = starting_num + i - 1
				local new_line = line:gsub("^(%s*)%d+([.)])(%s)", "%1" .. expected_num .. "%2%3", 1)
				if new_line ~= line then
					table.insert(changes, { row + i - 1, new_line }) -- 0-indexed
				end
			end
			-- Apply changes
			for _, change in ipairs(changes) do
				vim.api.nvim_buf_set_lines(0, change[1], change[1] + 1, false, { change[2] })
			end
		end

		-- Check if line is an empty list item and return indent + rest of prefix
		-- Returns: indent (spaces), prefix_without_indent, or nil if not empty
		local function get_empty_item_parts(line)
			-- Checkbox: "    - [ ] " -> "    ", "- [ ] "
			local ind, rest = line:match("^(%s*)([-*+]%s*%[.%]%s*)$")
			if ind then return ind, rest end
			ind, rest = line:match("^(%s*)(%d+[.)]%s*%[.%]%s*)$")
			if ind then return ind, rest end
			-- Bullet: "    - " -> "    ", "- "
			ind, rest = line:match("^(%s*)([-*+]%s*)$")
			if ind then return ind, rest end
			-- Numbered: "    1. " -> "    ", "1. "
			ind, rest = line:match("^(%s*)(%d+[.)]%s*)$")
			if ind then return ind, rest end
			-- Blockquote: "    > " -> "    ", "> "
			ind, rest = line:match("^(%s*)(>+%s*)$")
			if ind then return ind, rest end
			return nil, nil
		end

		local function handle_cr()
			local line = vim.api.nvim_get_current_line()
			local col = vim.api.nvim_win_get_cursor(0)[2]
			local row = vim.api.nvim_win_get_cursor(0)[1]

			-- Check for empty list item first (at end of line)
			if col >= #line then
				local ind, rest = get_empty_item_parts(line)
				if ind ~= nil then
					local new_line
					if #ind >= 4 then
						-- Decrease indent by 4 spaces (or 1 tab)
						local new_indent = ind:match("^\t") and ind:sub(2) or ind:sub(5)
						new_line = new_indent .. rest
					elseif #ind > 0 then
						-- Less than 4 spaces of indent, remove all indent
						new_line = rest
					else
						-- No indent, replace with empty line
						new_line = ""
					end
					vim.schedule(function()
						vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
						vim.api.nvim_win_set_cursor(0, { row, #new_line })
					end)
					return ""
				end
			end

			-- Blockquote continuation
			local prefix = line:match("^(%s*>+%s*)")
			local indent, sep, inserted_num = nil, nil, nil
			if not prefix then
				-- List continuation (checkbox > bullet > numbered)
				prefix = get_checkbox_prefix(line)
				if not prefix then
					prefix = get_bullet_prefix(line)
				end
				if not prefix then
					-- For numbered lists, get the new number
					local ind, num, s = line:match("^(%s*)(%d+)([.)])%s")
					if num and not line:match("^%s*%d+[.)]%s*%[.%]") then
						local new_num = tonumber(num) + 1
						prefix = ind .. new_num .. s .. " "
						indent, sep, inserted_num = ind, s, new_num
					end
				end
			end
			if prefix then
				-- Mid-line: split and prepend prefix to remainder
				if col < #line then
					local before = line:sub(1, col)
					local after = line:sub(col + 1)
					vim.schedule(function()
						-- Single set_lines call replaces one line with two = one undo entry
						vim.api.nvim_buf_set_lines(0, row - 1, row, false, { before, prefix .. after })
						vim.api.nvim_win_set_cursor(0, { row + 1, #prefix })
						-- Renumber if this is a numbered list
						if indent and sep and inserted_num then
							vim.cmd("undojoin")
							renumber_below(row + 1, inserted_num + 1, indent, sep)
						end
					end)
					return ""
				end
				-- End of line: insert new line with prefix
				vim.schedule(function()
					vim.api.nvim_buf_set_lines(0, row, row, false, { prefix })
					vim.api.nvim_win_set_cursor(0, { row + 1, #prefix })
					-- Renumber if this is a numbered list
					if indent and sep and inserted_num then
						renumber_below(row + 1, inserted_num + 1, indent, sep)
					end
				end)
				return ""
			end
			-- Default: normal enter
			return vim.api.nvim_replace_termcodes("<CR>", true, false, true)
		end

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function(ev)
				local o = { buffer = true }
				vim.keymap.set("n", "<leader>tt", toggle_checkbox, o)

				-- Insert new line with prefix (for list continuation)
				-- inserted_num is the number in the inserted prefix (for renumbering)
				local function insert_with_prefix(prefix, below, indent, sep, inserted_num)
					local row = vim.api.nvim_win_get_cursor(0)[1]
					local target = below and row or row - 1
					vim.api.nvim_buf_set_lines(0, target, target, false, { prefix })
					vim.api.nvim_win_set_cursor(0, { below and row + 1 or row, #prefix })
					-- Renumber if this is a numbered list
					if indent and sep and inserted_num then
						renumber_below(target + 1, inserted_num + 1, indent, sep)
					end
					vim.cmd("startinsert!")
				end

				-- Get prefix and numbered info for line continuation
				-- Returns: prefix, indent, sep, inserted_num (last 3 only for numbered lists)
				-- For 'o' (below): increment number
				-- For 'O' (above): use same number, renumber current and below
				local function get_list_prefix_and_info(line, below)
					local prefix = get_checkbox_prefix(line)
					if prefix then return prefix, nil, nil, nil end
					prefix = get_bullet_prefix(line)
					if prefix then return prefix, nil, nil, nil end
					-- For numbered lists, extract the number from the prefix
					local indent, num, sep = line:match("^(%s*)(%d+)([.)])%s")
					if num and not line:match("^%s*%d+[.)]%s*%[.%]") then
						local cur_num = tonumber(num)
						local new_num = below and (cur_num + 1) or cur_num
						return indent .. new_num .. sep .. " ", indent, sep, new_num
					end
					return nil, nil, nil, nil
				end

				-- o/O: list continuation (blockquote, checkbox, bullet, numbered)
				vim.keymap.set("n", "o", function()
					if blockquote_newline(true) then return end
					local prefix, indent, sep, num = get_list_prefix_and_info(vim.api.nvim_get_current_line(), true)
					if prefix then
						insert_with_prefix(prefix, true, indent, sep, num)
					else
						vim.cmd("normal! o")
						vim.cmd("startinsert")
					end
				end, o)
				vim.keymap.set("n", "O", function()
					if blockquote_newline(false) then return end
					local prefix, indent, sep, num = get_list_prefix_and_info(vim.api.nvim_get_current_line(), false)
					if prefix then
						insert_with_prefix(prefix, false, indent, sep, num)
					else
						vim.cmd("normal! O")
						vim.cmd("startinsert")
					end
				end, o)
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
