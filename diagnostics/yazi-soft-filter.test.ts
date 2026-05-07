/**
 * yazi soft-filter plugin — type-to-jump, n/N nav, Esc clears.
 *
 * Yazi has no native soft filter, so we override Entity.style to dim non-matches
 * and wire `/` to a Lua plugin that runs an interactive prompt. This suite covers
 * the user-visible behavior; the Entity.style dimming itself isn't asserted (would
 * require capture-pane -e + ANSI parsing for marginal value).
 *
 * We detect "what's hovered" via the status bar — init.lua renders the hovered
 * file's full path on the right, and the active filter chip on the left.
 *
 * Run: bun test yazi-soft-filter.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { $ } from "bun";
import { TmuxRunner } from "./lib";

const TEST_DIR = "/tmp/yazi-soft-filter-test";
const tmux = new TmuxRunner("yazi-soft-filter-test", TEST_DIR);

const KEY_DELAY = 250;
const PROMPT_DELAY = 600;
const TYPE_DELAY = 400;
// Esc waits for tmux's escape-time (default 500ms) before being dispatched as
// a standalone key, so we have to wait longer after sending it.
const ESC_DELAY = 1500;

// Sorted alphabetically by yazi: apple, apricot, banana, cherry, date.
// "ap" matches apple + apricot; "apr" matches only apricot.
const FILES = ["apple.txt", "apricot.txt", "banana.txt", "cherry.txt", "date.txt"];

beforeAll(async () => {
  await $`rm -rf ${TEST_DIR}`.quiet();
  await $`mkdir -p ${TEST_DIR}`.quiet();
  for (const name of FILES) {
    await Bun.write(`${TEST_DIR}/${name}`, "x\n");
  }
}, 10000);

afterAll(() => tmux.cleanup());

describe("yazi soft-filter — type-to-jump", () => {
  it("jumps to a match when the cursor is on a non-match (wraps from cursor)", async () => {
    await tmux.startYazi();
    await tmux.sendRaw("G", KEY_DELAY); // bottom: date.txt (no match for "apr")
    await tmux.sendRaw("/", PROMPT_DELAY);
    await tmux.sendLiteral("apr", TYPE_DELAY); // matches only apricot
    await tmux.sendRaw("Enter", KEY_DELAY); // commit, close prompt
    expect(await tmux.capture()).toContain("apricot.txt");
    await tmux.kill();
  }, 15000);

  it("stays on the current file if it already matches", async () => {
    await tmux.startYazi();
    await tmux.sendRaw("gg", KEY_DELAY); // top: apple.txt
    await tmux.sendRaw("/", PROMPT_DELAY);
    await tmux.sendLiteral("ap", TYPE_DELAY); // apple matches → stay
    await tmux.sendRaw("Enter", KEY_DELAY);
    expect(await tmux.capture()).toContain("apple.txt");
    await tmux.kill();
  }, 15000);
});

describe("yazi soft-filter — n/N navigation", () => {
  it("n advances to next match, N walks back", async () => {
    await tmux.startYazi();
    await tmux.sendRaw("gg", KEY_DELAY);
    await tmux.sendRaw("/", PROMPT_DELAY);
    await tmux.sendLiteral("ap", TYPE_DELAY); // matches apple, apricot
    await tmux.sendRaw("Enter", KEY_DELAY); // cursor stays on apple
    expect(await tmux.capture()).toContain("apple.txt");

    await tmux.sendRaw("n", KEY_DELAY);
    expect(await tmux.capture()).toContain("apricot.txt");

    await tmux.sendRaw("N", KEY_DELAY);
    expect(await tmux.capture()).toContain("apple.txt");
    await tmux.kill();
  }, 15000);
});

describe("yazi soft-filter — escape clears", () => {
  it("Esc inside the prompt clears and closes", async () => {
    await tmux.startYazi();
    await tmux.sendRaw("/", PROMPT_DELAY);
    await tmux.sendLiteral("xyz", TYPE_DELAY); // matches nothing
    await tmux.sendRaw("Escape", ESC_DELAY);
    // The status-bar filter chip uses the 󰈲 glyph; absent ⇒ filter cleared.
    expect(await tmux.capture()).not.toContain("󰈲");
    await tmux.kill();
  }, 15000);

  it("Esc at the manager clears a committed filter", async () => {
    await tmux.startYazi();
    await tmux.sendRaw("/", PROMPT_DELAY);
    await tmux.sendLiteral("xyz", TYPE_DELAY);
    await tmux.sendRaw("Enter", KEY_DELAY); // commit, chip should appear
    expect(await tmux.capture()).toContain("󰈲");
    await tmux.sendRaw("Escape", ESC_DELAY);
    expect(await tmux.capture()).not.toContain("󰈲");
    await tmux.kill();
  }, 15000);
});
