/**
 * yazi soft-filter plugin — type-to-jump, n/N nav, Esc clears.
 *
 * Yazi has no native soft filter, so we override Entity.style to dim non-matches
 * and wire `/` to a Lua plugin that runs an interactive prompt. This suite covers
 * the user-visible behavior; the Entity.style dimming itself isn't asserted (would
 * require capture-pane -e + ANSI parsing for marginal value).
 *
 * Anchors:
 *  - hovered file's absolute path is rendered on the bottom-right status bar.
 *  - active filter shows as ` 󰈲 <query>` on the bottom-left status bar.
 *
 * Run: bun test yazi-soft-filter.test.ts
 */

import { describe, it, beforeAll, afterAll } from "bun:test";
import { $ } from "bun";
import { TmuxRunner } from "./lib";

const TEST_DIR = "/tmp/yazi-soft-filter-test";
const tmux = new TmuxRunner("yazi-soft-filter-test");

const FILTER_CHIP = "󰈲";
// Soft-filter prompt has no visible indicator before chars are typed; a tiny
// wait gives yazi time to enter prompt mode so the next chars don't trigger
// manager-mode bindings (e.g. `a` = create file).
const PROMPT_OPEN = 100;

// Sorted alphabetically by yazi: apple, apricot, banana, cherry, date.
// "ap" matches apple + apricot; "apr" matches only apricot.
const FILES = ["apple.txt", "apricot.txt", "banana.txt", "cherry.txt", "date.txt"];
const hoveredPath = (name: string) => `${TEST_DIR}/${name}`;
const FILTER = (q: string) => `${FILTER_CHIP} ${q}`;

async function startYazi() {
  await tmux.start({ cmd: "yazi", cwd: TEST_DIR });
  await tmux.waitFor(hoveredPath("apple.txt")); // status bar populated ⇒ UI ready
}

beforeAll(async () => {
  await $`rm -rf ${TEST_DIR}`.quiet();
  await $`mkdir -p ${TEST_DIR}`.quiet();
  await Promise.all(FILES.map((name) => Bun.write(`${TEST_DIR}/${name}`, "x\n")));
}, 10000);

afterAll(async () => {
  await tmux.kill();
  await $`rm -rf ${TEST_DIR}`.nothrow();
});

describe("yazi soft-filter — type-to-jump", () => {
  it("jumps to a match when the cursor is on a non-match (wraps from cursor)", async () => {
    await startYazi();
    await tmux.sendRaw("G");
    await tmux.waitFor(hoveredPath("date.txt"));
    await tmux.sendRaw("/");
    await Bun.sleep(PROMPT_OPEN);
    await tmux.sendLiteral("apr");
    await tmux.waitFor(FILTER("apr"));
    await tmux.sendRaw("Enter");
    await tmux.waitFor(hoveredPath("apricot.txt"));
  }, 15000);

  it("stays on the current file if it already matches", async () => {
    await startYazi();
    await tmux.sendRaw("gg");
    await tmux.waitFor(hoveredPath("apple.txt"));
    await tmux.sendRaw("/");
    await Bun.sleep(PROMPT_OPEN);
    await tmux.sendLiteral("ap");
    await tmux.waitFor(FILTER("ap"));
    await tmux.sendRaw("Enter");
    await tmux.waitFor(hoveredPath("apple.txt"));
  }, 15000);
});

describe("yazi soft-filter — n/N navigation", () => {
  it("n advances to next match, N walks back", async () => {
    await startYazi();
    await tmux.sendRaw("gg");
    await tmux.waitFor(hoveredPath("apple.txt"));
    await tmux.sendRaw("/");
    await Bun.sleep(PROMPT_OPEN);
    await tmux.sendLiteral("ap");
    await tmux.waitFor(FILTER("ap"));
    await tmux.sendRaw("Enter");

    await tmux.sendRaw("n");
    await tmux.waitFor(hoveredPath("apricot.txt"));

    await tmux.sendRaw("N");
    await tmux.waitFor(hoveredPath("apple.txt"));
  }, 15000);
});

describe("yazi soft-filter — escape clears", () => {
  it("Esc inside the prompt clears and closes", async () => {
    await startYazi();
    await tmux.sendRaw("/");
    await Bun.sleep(PROMPT_OPEN);
    await tmux.sendLiteral("xyz");
    await tmux.waitFor(FILTER("xyz"));
    await tmux.sendRaw("Escape");
    await tmux.waitFor((s) => !s.includes(FILTER_CHIP));
  }, 15000);

  it("Esc at the manager clears a committed filter", async () => {
    await startYazi();
    await tmux.sendRaw("/");
    await Bun.sleep(PROMPT_OPEN);
    await tmux.sendLiteral("xyz");
    await tmux.waitFor(FILTER("xyz"));
    await tmux.sendRaw("Enter");
    await tmux.waitFor(FILTER("xyz")); // still present after commit
    await tmux.sendRaw("Escape");
    await tmux.waitFor((s) => !s.includes(FILTER_CHIP));
  }, 15000);
});
