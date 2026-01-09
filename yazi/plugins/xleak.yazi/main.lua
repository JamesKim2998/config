local M = {}

-- Fallback to bat for files xleak can't handle (e.g., HTML disguised as .xls)
local function preview_with_bat(job)
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
		:arg({ "--export", "text", tostring(job.file.url) })
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:output()

	-- If xleak fails (e.g., HTML file), fall back to bat
	if not output or not output.status.success then
		return preview_with_bat(job)
	end

	local lines = output.stdout
	if #lines == 0 then
		return preview_with_bat(job)
	end

	-- Process tabs
	local processed_text = lines:gsub("\t", "  ")
	ya.preview_widget(job, ui.Text(processed_text):area(job.area))
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
