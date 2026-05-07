--- Jump to a git worktree of the current repo.
--- Lists `git worktree list --porcelain` (run from yazi's cwd), reformats as
--- `<branch>\t<path>\t<sha>`, picks via fzf, `cd`s yazi to the chosen path.

local get_cwd = ya.sync(function() return tostring(cx.active.current.cwd) end)

local fail = function(s, ...)
	ya.notify { title = "worktree-jump", content = string.format(s, ...), timeout = 5, level = "error" }
end

-- Parse porcelain records (paragraph-separated). Two-pass awk: collect rows
-- and the longest branch name, then emit `branch\tpath\tsha` with the branch
-- field padded to that max so fzf renders aligned columns (tabstop=2 keeps
-- the inter-column gap minimal). $HOME → `~` for display; re-expanded on select.
-- Porcelain format: https://git-scm.com/docs/git-worktree#_porcelain_format
local awk_script = [[
BEGIN { RS=""; FS="\n"; n=0; maxname=0 }
{
  path=""; sha=""; name="(detached)"
  for (i=1; i<=NF; i++) {
    if (substr($i,1,9) == "worktree ") path = substr($i, 10)
    else if (substr($i,1,5) == "HEAD ")  sha  = substr($i, 6, 8)
    else if (substr($i,1,7) == "branch ") { name = substr($i, 8); sub(/^refs\/heads\//, "", name) }
  }
  disp = path
  hl = length(home)
  if (substr(disp, 1, hl) == home) disp = "~" substr(disp, hl+1)
  n++; names[n]=name; paths[n]=disp; shas[n]=sha
  if (length(name) > maxname) maxname = length(name)
}
END {
  for (i=1; i<=n; i++) printf "%-*s\t%s\t%s\n", maxname, names[i], paths[i], shas[i]
}
]]

local function entry()
	local cwd = get_cwd()
	local _permit = ui.hide()

	-- pipefail surfaces git's real exit code (e.g. 128 outside a repo) instead
	-- of fzf's, so we can distinguish "not a repo" from "user cancelled".
	local cmd = "set -o pipefail; git worktree list --porcelain | awk -v home=\"$HOME\" '"
		.. awk_script
		.. "' | fzf --delimiter='\t' --tabstop=2 --prompt='worktree> ' --layout=reverse --no-multi"

	local child, err = Command(os.getenv("SHELL") or "sh")
		:arg({ "-c", cmd })
		:cwd(cwd)
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

	-- Selection is `branch\tpath\tsha`; take the path field.
	local target = line:match("^[^\t]*\t([^\t]+)")
	if not target then return end
	if target:sub(1, 1) == "~" then
		target = (os.getenv("HOME") or "") .. target:sub(2)
	end
	ya.emit("cd", { target })
end

return { entry = entry }
