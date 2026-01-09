local M = {}

local decoder = (os.getenv("MEOW_ROOT") or os.getenv("HOME") .. "/Develop")
	.. "/meow-toolbox/src/langpack/tools/decode"

function M:peek(job)
	if not job.file then return end

	local child = Command("sh")
		:arg({ "-c", ya.quote(decoder) .. " " .. ya.quote(tostring(job.file.url)) .. " | bat --style=plain --color=always -l csv" })
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()

	if not child then
		return ya.preview_widget(job, ui.Text("Failed to spawn decoder"):area(job.area))
	end

	local lines, i = "", 0
	repeat
		local next, event = child:read_line()
		if event ~= 0 then break end
		i = i + 1
		if i > job.skip then lines = lines .. next end
	until i - job.skip >= job.area.h

	child:start_kill()

	if #lines == 0 then
		return ya.preview_widget(job, ui.Text("Empty or invalid langpack file"):area(job.area))
	end
	ya.preview_widget(job, ui.Text.parse(lines):area(job.area))
end

function M:seek(job)
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		ya.emit("peek", { math.max(0, cx.active.preview.skip + job.units), only_if = job.file.url })
	end
end

return M
