-- Preview Unity Sprite `.asset` files: the rendered sprite, then its info rows
-- and the YAML below. Rendering and the rows both come from the Rust
-- `unity-sprite-render` CLI, the same source the macOS Quick Look extension
-- reads. Any other `.asset` falls through to the bat previewer.
-- See `unity-sprite-render.md` (boxcat-rust-tools).
local M = {}

-- `unity-sprite-render` exit status for "not a Sprite" — see its `--help`.
local NOT_A_SPRITE = 3

local function path_of(job) return tostring(job.file.path or job.file.url) end

local function info(job)
	local out, err = Command("unity-sprite-render"):arg({ "--info", path_of(job) }):output()
	if not out then return nil, Err("spawn unity-sprite-render: %s", err) end
	if out.status.code == NOT_A_SPRITE then return nil end
	if not out.status.success then return nil, Err("unity-sprite-render --info: %s", out.stderr) end
	return out.stdout
end

-- The YAML through bat, `skip` lines in, at most `limit` lines.
local function yaml_lines(job, limit)
	local child = Command("bat")
		:arg({ "--style", "plain", "--color", "always", "-l", "yaml", path_of(job) })
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()
	if not child then return "" end
	local lines, i, taken = "", 0, 0
	while taken < limit do
		local next, event = child:read_line()
		if event ~= 0 then break end
		i = i + 1
		if i > job.skip then
			lines = lines .. next
			taken = taken + 1
		end
	end
	child:start_kill()
	return lines
end

function M:peek(job)
	local start = os.clock()
	local rows, err = info(job)
	if not rows then
		if err then ya.err(tostring(err)) end
		return require("bat"):peek(job)
	end

	local cache = ya.file_cache({ file = job.file, skip = 0 })
	if cache then
		local _, preload_err = self:preload(job)
		if preload_err then ya.err(tostring(preload_err)) end
	end
	ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))
	local shown = cache
		and fs.cha(cache)
		and ya.image_show(cache, ui.Rect({
			x = job.area.x,
			y = job.area.y,
			w = job.area.w,
			h = math.floor(job.area.h / 2),
		}))
	local image_h = shown and shown.h + 1 or 0

	local text_area = ui.Rect({
		x = job.area.x,
		y = job.area.y + image_h,
		w = job.area.w,
		h = math.max(0, job.area.h - image_h),
	})
	-- The rows stay put; only the YAML under them scrolls.
	local _, row_count = rows:gsub("\n", "")
	local yaml = yaml_lines(job, math.max(0, text_area.h - row_count - 1))
	if job.skip > 0 and #yaml == 0 then
		return ya.emit("peek", { math.max(0, job.skip - text_area.h), only_if = job.file.url, upper_bound = true })
	end
	ya.preview_widget(job, ui.Text.parse(rows .. "\n" .. yaml):area(text_area))
end

function M:seek(job) require("bat"):seek(job) end

-- Render into yazi's cache once per file; a non-sprite leaves no cache and
-- is not an error.
function M:preload(job)
	local cache = ya.file_cache({ file = job.file, skip = 0 })
	if not cache or fs.cha(cache) then return true end
	local out, err = Command("unity-sprite-render")
		:arg({
			path_of(job),
			"-o",
			tostring(cache),
			"--max-size",
			tostring(math.max(rt.preview.max_width, rt.preview.max_height)),
		})
		:stdout(Command.NULL)
		:output()
	if not out then return true, Err("spawn unity-sprite-render: %s", err) end
	if out.status.success or out.status.code == NOT_A_SPRITE then return true end
	return true, Err("unity-sprite-render: %s", out.stderr)
end

return M
