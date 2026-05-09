--- Resolve `(repo, branch, toplevel)` for the active cwd and cache it for
--- the status bar. See [[yazi.md#sandbox--render-path-gotcha]] for the
--- sync/async/plugin-context constraints that force this topology.

local M = { _cache = {} }

local set = ya.sync(function(self, cwd, info)
	self._cache[cwd] = info
	ui.render()
end)

local function compute_async(cwd)
	ya.async(function()
		local function run(args)
			local child = Command("git"):arg(args):cwd(cwd)
				:stdout(Command.PIPED):stderr(Command.PIPED):spawn()
			if not child then return "" end
			local out = child:wait_with_output()
			if not out or out.status.code ~= 0 then return "" end
			return (out.stdout or ""):gsub("\n$", "")
		end

		-- One fork for both paths: stdout is `<toplevel>\n<git-common-dir>\n`.
		local out = run({ "rev-parse", "--path-format=absolute", "--show-toplevel", "--git-common-dir" })
		local toplevel, common = out:match("^([^\n]*)\n([^\n]*)")
		if not toplevel or toplevel == "" then
			set(cwd, { repo = "", branch = "", toplevel = "" })
			return
		end
		-- `--git-common-dir` resolves to the shared `.git`, so all worktrees
		-- of the same repo report a single repo name.
		local repo = (common or ""):gsub("/%.git/?$", ""):match("([^/]+)/?$")
			or toplevel:match("([^/]+)/?$") or ""
		local branch = run({ "symbolic-ref", "--short", "-q", "HEAD" })
		if branch == "" then
			-- Detached HEAD: fall back to the worktree's directory basename
			-- (e.g. `ios-0` for our pool worktrees) — usually meaningful.
			branch = toplevel:match("([^/]+)/?$") or ""
		end
		set(cwd, { repo = repo, branch = branch, toplevel = toplevel })
	end)
end

function M:setup()
	ps.sub("cd", function()
		local cwd = tostring(cx.active.current.cwd)
		if not self._cache[cwd] then compute_async(cwd) end
	end)
end

-- Sync read for Status:redraw. Returns empty fields until the first `cd`
-- event has populated the cache for `cwd`.
function M.get(cwd)
	return M._cache[cwd] or { repo = "", branch = "", toplevel = "" }
end

return M
