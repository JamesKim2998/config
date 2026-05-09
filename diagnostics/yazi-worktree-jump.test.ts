/**
 * Tests for yazi/plugins/worktree-jump.yazi/main.lua's awk pipeline.
 *
 * Builds a temp git repo with fixed commit dates and multiple worktrees
 * (including a detached one), then runs the same `git worktree list
 * --porcelain | awk ... | sort | cut -f2-` pipeline the plugin runs and
 * asserts on the output.
 *
 * Run: bun test yazi-worktree-jump.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { $ } from "bun";
import {
  mkdtempSync,
  realpathSync,
  rmSync,
  readFileSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

// macOS tmpdir is /var/folders/... which is a symlink to /private/var/...
// `git worktree list --porcelain` emits canonical paths, so equality and
// $HOME-prefix replacement break unless we resolve test paths up front.
const mkRealTmp = (prefix: string) =>
  realpathSync(mkdtempSync(join(tmpdir(), prefix)));

const PLUGIN_LUA = join(
  import.meta.dir,
  "..",
  "yazi",
  "plugins",
  "worktree-jump.yazi",
  "main.lua",
);

// Extract the embedded awk script from main.lua so the test always exercises
// the same source the plugin ships.
function extractAwkScript(): string {
  const src = readFileSync(PLUGIN_LUA, "utf8");
  const m = src.match(/local awk_script = \[=*\[\n([\s\S]*?)\n\]=*\]/);
  if (!m) throw new Error("could not find awk_script in main.lua");
  return m[1];
}

const ANSI = /\x1b\[[0-9;]*m/g;
const stripAnsi = (s: string) => s.replace(ANSI, "");

interface Row {
  marker: string;
  branch: string;
  date: string;
  sha: string;
  path: string;
  subject: string;
}

function parseRow(line: string): Row {
  const fields = stripAnsi(line).split("\t");
  return {
    marker: fields[0],
    branch: (fields[1] ?? "").replace(/\s+$/, ""),
    date: fields[2],
    sha: fields[3],
    path: fields[4],
    subject: fields[5],
  };
}

let repo: string;
let pool: string;
let awkFile: string;

async function commitOn(
  cwd: string,
  branch: string,
  date: string,
  message: string,
) {
  await $`git checkout -b ${branch}`.cwd(cwd).quiet();
  await Bun.write(join(cwd, `${branch}.txt`), `${branch}\n`);
  await $`git add -A`.cwd(cwd).quiet();
  await $`git -c user.email=t@t -c user.name=t commit -m ${message}`
    .cwd(cwd)
    .env({
      ...process.env,
      GIT_AUTHOR_DATE: date,
      GIT_COMMITTER_DATE: date,
    })
    .quiet();
}

beforeAll(async () => {
  repo = mkRealTmp("wt-jump-");
  pool = mkRealTmp("wt-jump-pool-");

  await $`git init -b main ${repo}`.quiet();
  await Bun.write(join(repo, "README"), "x\n");
  await $`git add -A`.cwd(repo).quiet();
  await $`git -c user.email=t@t -c user.name=t commit -m main-initial`
    .cwd(repo)
    .env({
      ...process.env,
      GIT_AUTHOR_DATE: "2024-01-01T00:00:00Z",
      GIT_COMMITTER_DATE: "2024-01-01T00:00:00Z",
    })
    .quiet();

  // Branches with controlled commit dates.
  await commitOn(repo, "feature-old", "2024-02-10T00:00:00Z", "old work");
  await $`git checkout main`.cwd(repo).quiet();
  await commitOn(repo, "feature-new", "2024-03-15T00:00:00Z", "new work");
  await $`git checkout main`.cwd(repo).quiet();
  await commitOn(repo, "feature-mid", "2024-02-20T00:00:00Z", "mid work");
  await $`git checkout main`.cwd(repo).quiet();

  // Worktrees: branch-based + one detached.
  await $`git worktree add ${join(pool, "feature-new")} feature-new`
    .cwd(repo)
    .quiet();
  await $`git worktree add ${join(pool, "feature-old")} feature-old`
    .cwd(repo)
    .quiet();
  await $`git worktree add ${join(pool, "feature-mid")} feature-mid`
    .cwd(repo)
    .quiet();
  await $`git worktree add --detach ${join(pool, "detached")} HEAD`
    .cwd(repo)
    .quiet();

  awkFile = join(mkRealTmp("wt-jump-awk-"), "sort.awk");
  writeFileSync(awkFile, extractAwkScript());
});

afterAll(() => {
  for (const d of [repo, pool]) {
    try {
      rmSync(d, { recursive: true, force: true });
    } catch {}
  }
});

async function runPipeline(
  cwd: string,
  current: string,
  home = process.env.HOME ?? "",
): Promise<string> {
  const out =
    await $`bash -c "set -o pipefail; git worktree list --porcelain | awk -v home=${home} -v cur=${current} -f ${awkFile} | LC_ALL=C sort | cut -f2-"`
      .cwd(cwd)
      .text();
  return out;
}

// Lua syntax is checked by yazi-lua-syntax.test.ts; here we focus on the awk
// pipeline behavior. Regression note: the embedded awk uses `t[a[1]]` etc.,
// whose `]]` terminates a default `[[ ... ]]` long string — must stay on
// `[==[ ... ]==]`.
describe("worktree-jump awk pipeline", () => {
  it("pins current worktree at top with marker", async () => {
    const cur = join(pool, "feature-new");
    const lines = (await runPipeline(cur, cur)).trimEnd().split("\n");
    const top = parseRow(lines[0]);
    expect(top.marker).toBe("●");
    expect(top.branch).toBe("feature-new");
  });

  it("orders non-current rows by descending committer date", async () => {
    const cur = join(pool, "feature-new");
    const lines = (await runPipeline(cur, cur)).trimEnd().split("\n");
    const rest = lines.slice(1).map(parseRow);
    expect(rest.map((r) => r.branch)).toEqual([
      "feature-mid", // 2024-02-20
      "feature-old", // 2024-02-10
      "main", // 2024-01-01
    ]);
    // Markers on non-current rows are blank.
    for (const r of rest) expect(r.marker).toBe(" ");
  });

  it("skips detached HEAD worktrees", async () => {
    const cur = join(pool, "feature-new");
    const out = await runPipeline(cur, cur);
    expect(out).not.toContain("detached");
    expect(out).not.toContain("(detached)");
  });

  it("emits date (YYYY-MM-DD), 8-char sha, ~-prefixed path, subject", async () => {
    const cur = join(pool, "feature-new");
    const lines = (await runPipeline(cur, cur, pool)).trimEnd().split("\n");
    const top = parseRow(lines[0]);
    expect(top.date).toMatch(/^\d{4}-\d{2}-\d{2}$/);
    expect(top.date).toBe("2024-03-15");
    expect(top.sha).toMatch(/^[0-9a-f]{8}$/);
    // home=pool means the worktree path should be displayed under ~.
    expect(top.path.startsWith("~/")).toBe(true);
    expect(top.subject).toBe("new work");
  });

  it("colorizes columns with distinct ANSI codes", async () => {
    const cur = join(pool, "feature-new");
    const raw = await runPipeline(cur, cur);
    const firstLine = raw.split("\n")[0];
    // marker bright-yellow (93), branch green (32), date bright-black (90),
    // sha yellow (33), path blue (34).
    expect(firstLine).toContain("\x1b[93m");
    expect(firstLine).toContain("\x1b[32m");
    expect(firstLine).toContain("\x1b[90m");
    expect(firstLine).toContain("\x1b[33m");
    expect(firstLine).toContain("\x1b[34m");
    expect(firstLine).toContain("\x1b[0m");
  });

  it("falls back to blank marker when WT_ROOT is unset", async () => {
    const cur = join(pool, "feature-new");
    const lines = (await runPipeline(cur, "")).trimEnd().split("\n");
    for (const l of lines) {
      const r = parseRow(l);
      expect(r.marker).toBe(" ");
    }
    // No "current" → first row is just whatever sorts highest by date
    // (feature-new is newest).
    expect(parseRow(lines[0]).branch).toBe("feature-new");
  });
});
