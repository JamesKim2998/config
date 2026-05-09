/**
 * git-status cache inheritance — when cd lands in a subdir of an already-
 * resolved worktree, the bar must paint immediately with the cached
 * (repo, branch, toplevel) instead of waiting for an async git rev-parse
 * round-trip (which flashes an empty bar).
 *
 * Driven by a tiny Lua harness that mocks the yazi globals and captures
 * the `ps.sub("cd", …)` callback so we can fire it directly.
 */

import { describe, it, expect } from "bun:test";
import { $ } from "bun";
import { join } from "node:path";

const PLUGIN = join(
  import.meta.dir,
  "..",
  "yazi",
  "plugins",
  "git-status.yazi",
  "main.lua",
);

const HARNESS = `
-- Captures ps.sub callbacks; ya.async is a no-op so we observe only the
-- synchronous inherit path.
local _captured = {}
ps = { sub = function(kind, cb) _captured[kind] = cb end }
ya = {
  sync = function(fn)
    -- yazi auto-injects the plugin module table as the first arg; mirror that.
    return function(...) return fn(_G._mod, ...) end
  end,
  async = function(_) end,
  render = function() end,
}
ui = { render = function() end }
fs = { cha = function() return nil end }
Url = function(s) return s end
Command = setmetatable({ PIPED = 0, INHERIT = 1 }, {
  __call = function() return setmetatable({}, { __index = function(t) return function() return t end end }) end,
})

cx = { active = { current = { cwd = "" } } }

local M = dofile(os.getenv("PLUGIN_LUA"))
_G._mod = M
M:setup()

local function cd(p)
  cx.active.current.cwd = p
  _captured.cd()
end

-- Pre-populate as if compute_async had finished for /repo/X.
M._cache["/repo/X"] = { repo = "X-REPO", branch = "X-BRANCH", toplevel = "/repo/X" }

-- cd into a subdir of /repo/X — should inherit synchronously.
cd("/repo/X/sub/deep/dir")
local got = M.get("/repo/X/sub/deep/dir")
assert(got.repo == "X-REPO", "subdir repo: " .. tostring(got.repo))
assert(got.branch == "X-BRANCH", "subdir branch: " .. tostring(got.branch))
assert(got.toplevel == "/repo/X", "subdir toplevel: " .. tostring(got.toplevel))

-- cd into the toplevel itself — also a hit.
cd("/repo/X")
assert(M.get("/repo/X").repo == "X-REPO", "toplevel hit failed")

-- cd into an unrelated path — must not inherit; cache should stay empty
-- for that key (compute_async is a no-op in this harness, so a miss
-- means we never wrote anything).
cd("/elsewhere/unrelated")
assert(
  M._cache["/elsewhere/unrelated"] == nil,
  "unrelated cwd should not inherit"
)

print("OK")
`;

describe("git-status cache inherit", () => {
  it("intra-repo cd reuses cached (repo, branch, toplevel) synchronously", async () => {
    const r = await $`lua -e ${HARNESS}`
      .env({ ...process.env, PLUGIN_LUA: PLUGIN })
      .nothrow()
      .quiet();
    if (r.exitCode !== 0) {
      console.error("stdout:", r.stdout.toString());
      console.error("stderr:", r.stderr.toString());
    }
    expect(r.exitCode).toBe(0);
    expect(r.stdout.toString().trim()).toBe("OK");
  });
});
