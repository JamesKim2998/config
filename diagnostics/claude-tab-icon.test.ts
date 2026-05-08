/**
 * Claude Code → kitty tab busy-icon hook E2E test
 * Run: bun test claude-tab-icon.test.ts
 *
 * Manually-renamed tabs bypass `tab_title_template`, so we mutate the tab title
 * in-place via kitty/claude-busy.py: append " " on prompt, strip on stop.
 * Template-driven tabs are left untouched.
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { $ } from "bun";

const HOME = process.env.HOME!;
const SETTINGS = `${HOME}/Develop/config/.claude/settings.json`;
const SCRIPT = `${HOME}/Develop/config/kitty/claude-busy.py`;
const ICON = "";
const SUFFIX = " " + ICON;

describe("claude-busy.py", () => {
  it("settings.json wires UserPromptSubmit + Stop to claude-busy.py", async () => {
    const cfg = await Bun.file(SETTINGS).json();
    const submit = cfg.hooks?.UserPromptSubmit?.[0]?.hooks?.[0]?.command ?? "";
    const stop = cfg.hooks?.Stop?.[0]?.hooks?.[0]?.command ?? "";
    expect(submit).toContain("claude-busy.py set");
    expect(stop).toContain("claude-busy.py clear");
    expect(stop).toContain("\\a"); // bell still fires
  });

  it("script exists and is executable", async () => {
    const f = Bun.file(SCRIPT);
    expect(await f.exists()).toBe(true);
    const stat = await $`test -x ${SCRIPT}`.nothrow();
    expect(stat.exitCode).toBe(0);
  });

  describe("e2e against live kitty", () => {
    const sock = process.env.KITTY_LISTEN_ON;
    const winId = process.env.KITTY_WINDOW_ID;
    if (!sock || !winId) {
      it.skip("not running inside kitty — skipping live tests", () => {});
      return;
    }

    let originalTitle = "";
    let originalOverridden = false;

    beforeAll(async () => {
      const ls = await $`kitty @ --to=${sock} ls`.quiet().json();
      const tab = findMyTab(ls, parseInt(winId));
      originalTitle = tab?.title ?? "";
      originalOverridden = tab?.title_overridden ?? false;
      // Force a manual override so the script will act.
      await $`kitty @ --to=${sock} set-tab-title -- "test-tab"`.quiet();
    });

    afterAll(async () => {
      // Restore: clear override if it wasn't set originally.
      if (originalOverridden) {
        await $`kitty @ --to=${sock} set-tab-title -- ${originalTitle}`.quiet();
      } else {
        await $`kitty @ --to=${sock} set-tab-title`.quiet().nothrow();
      }
    });

    it("set appends icon when manually titled", async () => {
      await $`${SCRIPT} set`.quiet();
      const ls = await $`kitty @ --to=${sock} ls`.quiet().json();
      const tab = findMyTab(ls, parseInt(winId));
      expect(tab?.title).toBe("test-tab" + SUFFIX);
    });

    it("set is idempotent — won't double-append", async () => {
      await $`${SCRIPT} set`.quiet();
      await $`${SCRIPT} set`.quiet();
      const ls = await $`kitty @ --to=${sock} ls`.quiet().json();
      const tab = findMyTab(ls, parseInt(winId));
      expect(tab?.title).toBe("test-tab" + SUFFIX);
    });

    it("clear strips icon", async () => {
      await $`${SCRIPT} clear`.quiet();
      const ls = await $`kitty @ --to=${sock} ls`.quiet().json();
      const tab = findMyTab(ls, parseInt(winId));
      expect(tab?.title).toBe("test-tab");
    });

    it("clear is a no-op when icon absent", async () => {
      await $`${SCRIPT} clear`.quiet();
      const ls = await $`kitty @ --to=${sock} ls`.quiet().json();
      const tab = findMyTab(ls, parseInt(winId));
      expect(tab?.title).toBe("test-tab");
    });

    it("skips template-driven tabs (no override)", async () => {
      // Reset to template-driven for this case
      await $`kitty @ --to=${sock} set-tab-title`.quiet().nothrow();
      const before = await $`kitty @ --to=${sock} ls`.quiet().json();
      const t1 = findMyTab(before, parseInt(winId));
      expect(t1?.title_overridden).toBe(false);

      await $`${SCRIPT} set`.quiet();
      const after = await $`kitty @ --to=${sock} ls`.quiet().json();
      const t2 = findMyTab(after, parseInt(winId));
      expect(t2?.title_overridden).toBe(false); // still not overridden
      expect(t2?.title).not.toContain(ICON);

      // Restore manual title for afterAll cleanup
      await $`kitty @ --to=${sock} set-tab-title -- "test-tab"`.quiet();
    });
  });
});

function findMyTab(ls: any[], winId: number): any | null {
  for (const o of ls) for (const t of o.tabs ?? []) for (const w of t.windows ?? [])
    if (w.id === winId) return t;
  return null;
}
