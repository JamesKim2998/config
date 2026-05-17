/**
 * `wt go <TAB>` zsh completion picker.
 *
 * Regression: the completion in .zshrc used to filter `awk '$2=="held"'`
 * against `wt ls` output, but `wt ls` already strips the STATE column —
 * so the filter matched nothing and TAB silently expanded to nothing.
 *
 * Run: bun test wt-completion.test.ts
 */

import { describe, it, expect } from "bun:test";
import { $ } from "bun";

// `wt ls` output shapes — header + separator + held rows.
// cmd_ls (bin/wt) drops the STATE and NAME columns from `worktree-pool ls`;
// when groups are uniform across held slots it also drops GROUP.
const WT_LS_WITH_GROUP = [
  "ID      GROUP  AGE  SHA       BRANCH   DIRTY  UNTRK  AHEAD",
  "------  -----  ---  --------  -------  -----  -----  -----",
  "feat-x  ios    2h   abc12345  main     0      0      0",
  "feat-y  and    1d   def67890  feature  2      1      3",
].join("\n");

const WT_LS_NO_GROUP = [
  "ID      AGE  SHA       BRANCH   DIRTY  UNTRK  AHEAD",
  "------  ---  --------  -------  -----  -----  -----",
  "feat-x  2h   abc12345  main     0      0      0",
].join("\n");

const WT_LS_EMPTY = "(no held slots)";

// Drive `_wt_go_pick` inside an interactive zsh so .zshrc is sourced,
// then shadow `wt` and `fzf` with stubs. fzf stand-in picks first line.
// Heredoc (quoted delimiter) keeps the sample's newlines/spaces verbatim.
async function pick(sample: string): Promise<string> {
  const script = `wt() { cat <<'EOF_WT_LS'
${sample}
EOF_WT_LS
}
fzf() { head -n1; }
_wt_go_pick
`;
  const result = await $`zsh -i -c ${script}`.text();
  return result.trim();
}

describe("_wt_go_pick", () => {
  it("yields first held slot when GROUP column is present", async () => {
    expect(await pick(WT_LS_WITH_GROUP)).toBe("feat-x");
  });

  it("yields first held slot when GROUP column is dropped", async () => {
    expect(await pick(WT_LS_NO_GROUP)).toBe("feat-x");
  });

  it("yields nothing when no held slots", async () => {
    expect(await pick(WT_LS_EMPTY)).toBe("");
  });

  // Perf regression: default `wt ls` runs `git status --porcelain` per held
  // slot (~1s × N on cold Unity caches). The picker only needs slot names,
  // so it must pass `--bare`. Stub `wt`: sleep 2s unless --bare is in argv.
  it("invokes `wt ls --bare` (skips git-status for snappy TAB)", async () => {
    const script = `wt() {
  case "$*" in
    *--bare*) ;;
    *) sleep 2 ;;
  esac
  cat <<'EOF_WT_LS'
ID      AGE  SHA
------  ---  --------
feat-x  2h   abc12345
EOF_WT_LS
}
fzf() { head -n1; }
_wt_go_pick
`;
    const start = Date.now();
    const out = (await $`zsh -i -c ${script}`.text()).trim();
    const elapsed = Date.now() - start;
    expect(out).toBe("feat-x");
    expect(elapsed).toBeLessThan(1500);
  });
});
