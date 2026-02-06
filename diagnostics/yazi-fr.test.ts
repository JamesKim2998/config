/**
 * yazi fr.yazi plugin tests
 * Tests for rg search via 'S' keybinding
 *
 * Issues tested:
 * 1. Case sensitivity: rg search should be case-insensitive
 * 2. Reveal navigation: selecting a result should navigate yazi to that file
 *
 * Run: bun test yazi-fr.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { TmuxRunner } from "./lib";

const TEST_DIR = "/tmp/yazi-fr-test";
const tmux = new TmuxRunner("yazi-fr-test", TEST_DIR);

const FZF_OPEN_DELAY = 1000;
const SEARCH_DELAY = 1000;
const REVEAL_DELAY = 1500;

beforeAll(async () => {
  await Bun.write(`${TEST_DIR}/lowercase.txt`, "this file has hello world in lowercase\n");
  await Bun.write(`${TEST_DIR}/uppercase.txt`, "THIS FILE HAS HELLO WORLD IN UPPERCASE\n");
  await Bun.write(`${TEST_DIR}/mixedcase.txt`, "This File Has Hello World in MixedCase\n");
  await Bun.write(`${TEST_DIR}/subdir/nested.txt`, "nested file with hello world content\n");
}, 10000);

afterAll(() => tmux.cleanup());

describe("yazi fr.yazi case sensitivity", () => {
  it("should find all case variants when searching lowercase 'hello'", async () => {
    await tmux.startYazi();
    await tmux.sendRaw("S", FZF_OPEN_DELAY);
    await tmux.sendLiteral("hello", SEARCH_DELAY);

    const output = await tmux.capture();
    expect(output).toContain("4/4");

    await tmux.kill();
  }, 15000);

  it("should find all case variants when searching uppercase 'HELLO'", async () => {
    await tmux.startYazi();
    await tmux.sendRaw("S", FZF_OPEN_DELAY);
    await tmux.sendLiteral("HELLO", SEARCH_DELAY);

    const output = await tmux.capture();
    expect(output).toContain("4/4");

    await tmux.kill();
  }, 15000);
});

describe("yazi fr.yazi reveal navigation", () => {
  it("should navigate to selected file in current directory", async () => {
    await tmux.startYazi();
    await tmux.sendRaw("S", FZF_OPEN_DELAY);
    await tmux.sendLiteral("lowercase", SEARCH_DELAY);
    await tmux.sendRaw("Enter", REVEAL_DELAY);

    const output = await tmux.capture();
    expect(output).toContain(`${TEST_DIR}/lowercase.txt`);

    await tmux.kill();
  }, 15000);

  it("should navigate to selected file in subdirectory", async () => {
    await tmux.startYazi();
    await tmux.sendRaw("S", FZF_OPEN_DELAY);
    await tmux.sendLiteral("nested", SEARCH_DELAY);
    await tmux.sendRaw("Enter", REVEAL_DELAY);

    const output = await tmux.capture();
    expect(output).toContain(`${TEST_DIR}/subdir/nested.txt`);

    await tmux.kill();
  }, 15000);
});
