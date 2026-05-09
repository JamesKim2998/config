--- Jump to a git worktree of the current repo.
--- Lists `git worktree list --porcelain` (run from yazi's cwd), reformats as
--- `<branch>\t<path>\t<sha>`, picks via fzf, `cd`s yazi to the chosen path.
--- Preserves the rel path from the current worktree root: jumps to
--- `<target>/<rel>` when it exists, else falls back to `<target>` and notifies.

local get_cwd = ya.sync(function() return tostring(cx.active.current.cwd) end)

local fail = function(s, ...)
	ya.notify { title = "worktree-jump", content = string.format(s, ...), timeout = 5, level = "error" }
end

-- Run a command, return trimmed stdout on exit 0, else nil.
local function run_capture(cmd, args, cwd)
	local builder = Command(cmd):arg(args):stdout(Command.PIPED):stderr(Command.PIPED)
	if cwd then builder = builder:cwd(cwd) end
	local child = builder:spawn()
	if not child then return nil end
	local out = child:wait_with_output()
	if not out or out.status.code ~= 0 then return nil end
	return (out.stdout or ""):gsub("\n$", "")
end

local function dir_exists(path)
	local cha = fs.cha(Url(path))
	return cha ~= nil and cha.is_dir
end

-- Parse porcelain records (paragraph-separated). BEGIN preloads
-- branch → {committer-unix, short-date, subject} via `git for-each-ref` so we
-- can sort by recency and surface the latest commit. Emit
-- `<sortkey>\tmark\tbranch\tdate\tsha\tpath\tsubject` where sortkey is "0"
-- for the current worktree (matched against `cur`) and `1<inverted-time>`
-- (zero-padded so a lexicographic sort yields descending time) otherwise.
-- The branch field is padded to maxname so fzf renders aligned columns
-- (tabstop=2 keeps the inter-column gap minimal); date is fixed at 10 chars
-- (YYYY-MM-DD) and sha at 8, so all columns up to and including sha align.
-- $HOME → `~` for display; re-expanded on select. Detached HEAD worktrees
-- are skipped. Downstream `sort | cut -f2-` strips the key.
--
-- Per-column ANSI colors (rendered by fzf --ansi):
--   marker  bright-yellow (93)  attention pull on the current row
--   branch  green (32)          git convention; primary identifier
--   date    bright-black (90)   recedes; secondary
--   sha     yellow (33)         git convention; secondary
--   path    blue (34)           filesystem convention
--   subject default              highest contrast for the most info-dense column
--
-- Porcelain format: https://git-scm.com/docs/git-worktree#_porcelain_format
--
-- Note: level-2 long brackets `[==[ ... ]==]` so the embedded awk's `]]`
-- (e.g. `t[a[1]]`) doesn't terminate the Lua string.
local awk_script = [==[
BEGIN {
  ESC = sprintf("%c", 27); RST = ESC "[0m"
  C_MARK = ESC "[93m"; C_BR = ESC "[32m"; C_DT = ESC "[90m"
  C_SHA = ESC "[33m"; C_PATH = ESC "[34m"
  cmd = "git for-each-ref --format=\"%(refname:short)\t%(committerdate:unix)\t%(committerdate:format:%Y-%m-%d)\t%(contents:subject)\" refs/heads"
  while ((cmd | getline l) > 0) {
    split(l, a, "\t")
    t[a[1]] = a[2]; d[a[1]] = a[3]; s[a[1]] = a[4]
  }
  close(cmd)
  RS=""; FS="\n"; n=0; maxname=0
}
{
  path=""; sha=""; name=""; has_branch=0
  for (i=1; i<=NF; i++) {
    if (substr($i,1,9) == "worktree ") path = substr($i, 10)
    else if (substr($i,1,5) == "HEAD ")  sha  = substr($i, 6, 8)
    else if (substr($i,1,7) == "branch ") { name = substr($i, 8); sub(/^refs\/heads\//, "", name); has_branch=1 }
  }
  if (!has_branch) next
  disp = path
  hl = length(home)
  if (substr(disp, 1, hl) == home) disp = "~" substr(disp, hl+1)
  n++; names[n]=name; paths[n]=disp; shas[n]=sha; raws[n]=path
  tims[n]=(t[name]+0); dates[n]=(d[name] ? d[name] : "----------"); subjects[n]=s[name]
  if (length(name) > maxname) maxname = length(name)
}
END {
  for (i=1; i<=n; i++) {
    if (raws[i] == cur) { key = "0"; mark = "●" }
    else { key = sprintf("1%010d", 9999999999 - tims[i]); mark = " " }
    printf "%s\t%s%s%s\t%s%-*s%s\t%s%s%s\t%s%s%s\t%s%s%s\t%s\n",
      key,
      C_MARK, mark, RST,
      C_BR, maxname, names[i], RST,
      C_DT, dates[i], RST,
      C_SHA, shas[i], RST,
      C_PATH, paths[i], RST,
      subjects[i]
  }
}
]==]

local function entry()
	local cwd = get_cwd()

	-- Capture rel path from current worktree root before opening fzf, so we can
	-- mirror the same subdirectory in the target worktree.
	local rel = ""
	local root = run_capture("git", { "rev-parse", "--show-toplevel" }, cwd)
	if root and root ~= "" and cwd:sub(1, #root + 1) == root .. "/" then
		rel = cwd:sub(#root + 2)
	end

	-- Short-circuit non-repo / single-worktree cases — fzf with zero or one
	-- candidate is just noise. `git worktree list --porcelain` exits 128
	-- outside a repo (run_capture returns nil), and emits one `^worktree `
	-- record per worktree otherwise.
	local porcelain = run_capture("git", { "worktree", "list", "--porcelain" }, cwd)
	if not porcelain then
		return fail("not in a git repo")
	end
	local n = 0
	for line in (porcelain .. "\n"):gmatch("([^\n]*)\n") do
		if line:sub(1, 9) == "worktree " then n = n + 1 end
	end
	if n <= 1 then
		return ya.notify {
			title = "worktree-jump",
			content = "single worktree",
			timeout = 2,
			level = "warn",
		}
	end

	local _permit = ui.hide()

	-- pipefail surfaces git's real exit code (e.g. 128 outside a repo) instead
	-- of fzf's, so we can distinguish "not a repo" from "user cancelled".
	-- WT_ROOT is passed via env so awk can float the current worktree to the
	-- top. `LC_ALL=C sort` orders by the leading sortkey lexicographically
	-- (current first, then descending commit time); `cut -f2-` strips it.
	local cmd = "set -o pipefail; git worktree list --porcelain | awk -v home=\"$HOME\" -v cur=\"$WT_ROOT\" '"
		.. awk_script
		.. "' | LC_ALL=C sort | cut -f2- | fzf --ansi --delimiter='\t' --tabstop=2 --prompt='worktree> ' --layout=reverse --no-multi"

	local child, err = Command(os.getenv("SHELL") or "sh")
		:arg({ "-c", cmd })
		:cwd(cwd)
		:env("WT_ROOT", root or "")
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:stderr(Command.INHERIT)
		:spawn()

	if not child then
		return fail("spawn failed: %s", err)
	end

	local output, werr = child:wait_with_output()
	if not output then
		return fail("wait failed: %s", werr)
	elseif output.status.code == 130 then
		return -- user cancelled (Esc / Ctrl-C)
	elseif output.status.code == 1 then
		return ya.notify { title = "worktree-jump", content = "no worktree selected", timeout = 3 }
	elseif output.status.code == 128 then
		return fail("not in a git repo")
	elseif output.status.code ~= 0 then
		return fail("pipeline exited with %s", output.status.code)
	end

	local line = output.stdout:gsub("\n$", "")
	if line == "" then return end

	-- fzf preserves ANSI codes in its output; strip before splitting fields.
	line = line:gsub("\27%[[%d;]*m", "")

	-- Selection columns: mark, branch (right-padded), date, sha, path, subject.
	local fields = {}
	for f in (line .. "\t"):gmatch("([^\t]*)\t") do
		fields[#fields + 1] = f
	end
	local branch = (fields[2] or ""):gsub("%s+$", "")
	local target = fields[5]
	if not target or target == "" then return end
	if target:sub(1, 1) == "~" then
		target = (os.getenv("HOME") or "") .. target:sub(2)
	end

	local final, rel_missing = target, false
	if rel ~= "" then
		local candidate = target .. "/" .. rel
		if dir_exists(candidate) then
			final = candidate
		else
			rel_missing = true
		end
	end

	ya.emit("cd", { final })

	if rel_missing then
		ya.notify {
			title = "worktree-jump",
			content = string.format("%s — `%s` missing, jumped to root", branch, rel),
			timeout = 4,
		}
	else
		ya.notify { title = "worktree-jump", content = branch, timeout = 2 }
	end
end

return { entry = entry }
