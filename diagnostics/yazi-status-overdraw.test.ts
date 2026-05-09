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
import { mkdtempSync, realpathSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const REPO_MARK = "MARKERREPO";
const BRANCH_MARK = "MARKERBRANCH";
const LONG_FILE =
  "very_long_filename_to_force_overlap_between_path_and_repo_left.txt";

let repoDir: string;
const tmux = new TmuxRunner("yazi-overdraw", "/tmp/yazi-overdraw-placeholder");

beforeAll(async () => {
  const root = realpathSync(mkdtempSync(join(tmpdir(), "yazi-overdraw-")));
  repoDir = join(root, REPO_MARK);
  await $`mkdir -p ${repoDir}`.quiet();
  await $`git init -b main ${repoDir}`.quiet();
  await Bun.write(join(repoDir, "README"), "x\n");
  await $`git -C ${repoDir} -c user.email=t@t -c user.name=t add -A`.quiet();
  await $`git -C ${repoDir} -c user.email=t@t -c user.name=t commit -m init`.quiet();
  await $`git -C ${repoDir} checkout -b ${BRANCH_MARK}`.quiet();
  await Bun.write(join(repoDir, LONG_FILE), "x\n");
  // Point tmux at the test repo (constructor sets a placeholder).
  (tmux as unknown as { testDir: string }).testDir = repoDir;
}, 15000);

afterAll(async () => {
  await tmux.kill();
});

describe("yazi status bar overdraw", () => {
  it("repo + branch stay visible behind long hovered path", async () => {
    // Force a narrow terminal so left + right collide horizontally.
    await tmux.kill();
    await $`tmux new-session -d -s ${tmux.session} -x 80 -y 24 -c ${repoDir} yazi`.quiet();
    await Bun.sleep(2200);
    // Order is .git → README → very_long_…; jj reaches the long file.
    await tmux.sendRaw("j", 250);
    await tmux.sendRaw("j", 600);
    const out = await tmux.capture();
    if (process.env.DEBUG) {
      const lines = out.split("\n");
      lines.forEach((l, i) =>
        console.log(`[${String(i).padStart(2, " ")}] ${JSON.stringify(l)}`),
      );
    }
    // The bar is the last non-empty line in tmux's capture.
    const bottom =
      out.split("\n").reverse().find((l) => l.trim() !== "") ?? "";
    expect(bottom).toContain(REPO_MARK);
    expect(bottom).toContain(BRANCH_MARK);
  }, 20000);
});
