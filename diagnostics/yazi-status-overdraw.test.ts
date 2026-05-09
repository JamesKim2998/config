/**
 * Status bar overdraw — repo + branch (left) must remain visible when the
 * hovered file's path (right) is long enough to cross into the left half.
 *
 * Repro: narrow terminal (80 cols) + a 60+ char filename → right-aligned
 * path crosses the left margin. With the wrong render order the path is
 * drawn last and clobbers the repo/branch markers.
 *
 * Run: bun test yazi-status-overdraw.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { $ } from "bun";
import { TmuxRunner } from "./lib";
import { mkdtempSync, realpathSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const REPO_MARK = "MARKERREPO";
const BRANCH_MARK = "MARKERBRANCH";
const LONG_FILE =
  "very_long_filename_to_force_overlap_between_path_and_repo_left.txt";

let root: string;
let repoDir: string;
const tmux = new TmuxRunner("yazi-overdraw");

beforeAll(async () => {
  root = realpathSync(mkdtempSync(join(tmpdir(), "yazi-overdraw-")));
  repoDir = join(root, REPO_MARK);
  await $`mkdir -p ${repoDir}`.quiet();
  await $`git init -b main ${repoDir}`.quiet();
  await Bun.write(join(repoDir, "README"), "x\n");
  await $`git -C ${repoDir} -c user.email=t@t -c user.name=t add -A`.quiet();
  await $`git -C ${repoDir} -c user.email=t@t -c user.name=t commit -m init`.quiet();
  await $`git -C ${repoDir} checkout -b ${BRANCH_MARK}`.quiet();
  await Bun.write(join(repoDir, LONG_FILE), "x\n");
}, 15000);

afterAll(async () => {
  await tmux.kill();
  try { rmSync(root, { recursive: true, force: true }); } catch {}
});

describe("yazi status bar overdraw", () => {
  it("repo + branch stay visible behind long hovered path", async () => {
    await tmux.start({ cmd: "yazi", cwd: repoDir, cols: 80, rows: 24 });
    // Long names are truncated with `…` in the file list, so match a prefix.
    await tmux.waitFor(LONG_FILE.slice(0, 20));
    // Order is .git → README → very_long_…; jj reaches the long file.
    await tmux.sendRaw("j");
    await tmux.sendRaw("j");
    // Wait until the bottom row reflects the new hover. Match the path's
    // tail (right-aligned, always visible) — its head is what we're testing
    // gets overdrawn by the repo/branch labels, so it can't be the anchor.
    const out = await tmux.waitFor((s) => {
      const bottom = s.split("\n").reverse().find((l) => l.trim() !== "") ?? "";
      return bottom.includes(LONG_FILE.slice(-20));
    });
    if (process.env.DEBUG) {
      out.split("\n").forEach((l, i) =>
        console.log(`[${String(i).padStart(2, " ")}] ${JSON.stringify(l)}`),
      );
    }
    const bottom = out.split("\n").reverse().find((l) => l.trim() !== "") ?? "";
    expect(bottom).toContain(REPO_MARK);
    expect(bottom).toContain(BRANCH_MARK);
  }, 20000);
});
