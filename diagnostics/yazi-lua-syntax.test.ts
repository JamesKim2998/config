/**
 * Up-front syntax check for our owned yazi Lua.
 *
 * Catches errors like the `[[ ... ]]` long-string getting truncated by
 * embedded `]]` (e.g. awk's `t[a[1]]`) — yazi otherwise silently fails to
 * load the file. Vendored plugins (`yazi/plugins/<x>.yazi/` managed by
 * `ya pkg`) are excluded; we only own `init.lua` and `worktree-jump.yazi`.
 *
 * Run: bun test yazi-lua-syntax.test.ts
 */

import { describe, it, expect } from "bun:test";
import { $ } from "bun";
import { join } from "node:path";

const ROOT = join(import.meta.dir, "..", "yazi");

const OWNED = [
  "init.lua",
  "plugins/worktree-jump.yazi/main.lua",
  "plugins/git-status.yazi/main.lua",
];

describe("yazi lua syntax", () => {
  for (const rel of OWNED) {
    it(`luac -p ${rel}`, async () => {
      const r = await $`luac -p ${join(ROOT, rel)}`.nothrow().quiet();
      if (r.exitCode !== 0) {
        // Surface luac's message — it points at the offending line.
        console.error(r.stderr.toString());
      }
      expect(r.exitCode).toBe(0);
    });
  }
});
