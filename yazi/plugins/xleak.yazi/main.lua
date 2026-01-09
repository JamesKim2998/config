local M = {}

-- Preview text through bat with CSV syntax highlighting
local function preview_with_bat(job, text, lang)
	local child = Command("bat")
		:arg({ "--style", "plain", "--color", "always", "-l", lang or "csv" })
		:stdin(Command.PIPED)
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()

	if not child then return end

	child:write_all(text)
	child:flush()

	local max_lines = job.area.h
	local collected_lines = ""
	local i = 0
	local last_line = 0

	repeat
		local next, event = child:read_line()
		if event ~= 0 then break end
		i = i + 1
		if i > job.skip then
			collected_lines = collected_lines .. next
			last_line = last_line + 1
		end
	until last_line >= max_lines

	child:start_kill()
	ya.preview_widget(job, ui.Text.parse(collected_lines):area(job.area))
end

-- Fallback: preview file directly with bat
local function preview_file_with_bat(job)
	local child = Command("bat")
		:arg({ "--style", "plain", "--color", "always", tostring(job.file.url) })
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()

	if not child then return end

	local max_lines = job.area.h
	local collected_lines = ""
	local i = 0
	local last_line = 0

	repeat
		local next, event = child:read_line()
		if event ~= 0 then break end
		i = i + 1
		if i > job.skip then
			collected_lines = collected_lines .. next
			last_line = last_line + 1
		end
	until last_line >= max_lines

	child:start_kill()
	ya.preview_widget(job, ui.Text.parse(collected_lines):area(job.area))
end

function M:peek(job)
	if not job.file then return end

	-- Try xleak first
	local output = Command("xleak")
		:arg({ "--export", "csv", tostring(job.file.url) })
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:output()

	-- If xleak fails (e.g., HTML file), fall back to bat on raw file
	if not output or not output.status.success then
		return preview_file_with_bat(job)
	end

	local csv = output.stdout
	if #csv == 0 then
		return preview_file_with_bat(job)
	end

	-- Pipe CSV through bat for syntax highlighting
	preview_with_bat(job, csv, "csv")
end

function M:seek(job)
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		ya.emit("peek", {
			math.max(0, cx.active.preview.skip + job.units),
			only_if = job.file.url,
		})
	end
end

return M
