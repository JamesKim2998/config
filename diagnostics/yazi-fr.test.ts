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

import { describe, it, beforeAll, afterAll } from "bun:test";
import { $ } from "bun";
import { TmuxRunner } from "./lib";

const TEST_DIR = "/tmp/yazi-fr-test";
const tmux = new TmuxRunner("yazi-fr-test");

async function startYazi() {
  await tmux.start({ cmd: "yazi", cwd: TEST_DIR });
  await tmux.waitFor("lowercase.txt"); // file row visible ⇒ UI ready
}

beforeAll(async () => {
  await Promise.all([
    Bun.write(`${TEST_DIR}/lowercase.txt`, "this file has hello world in lowercase\n"),
    Bun.write(`${TEST_DIR}/uppercase.txt`, "THIS FILE HAS HELLO WORLD IN UPPERCASE\n"),
    Bun.write(`${TEST_DIR}/mixedcase.txt`, "This File Has Hello World in MixedCase\n"),
    Bun.write(`${TEST_DIR}/subdir/nested.txt`, "nested file with hello world content\n"),
  ]);
}, 10000);

afterAll(async () => {
  await tmux.kill();
  await $`rm -rf ${TEST_DIR}`.nothrow();
});

describe("yazi fr.yazi case sensitivity", () => {
  it("should find all case variants when searching lowercase 'hello'", async () => {
    await startYazi();
    await tmux.sendRaw("S");
    await tmux.sendLiteral("hello");
    await tmux.waitFor("4/4");
  }, 15000);

  it("should find all case variants when searching uppercase 'HELLO'", async () => {
    await startYazi();
    await tmux.sendRaw("S");
    await tmux.sendLiteral("HELLO");
    await tmux.waitFor("4/4");
  }, 15000);
});

describe("yazi fr.yazi reveal navigation", () => {
  it("should navigate to selected file in current directory", async () => {
    await startYazi();
    await tmux.sendRaw("S");
    await tmux.sendLiteral("lowercase");
    await tmux.waitFor("lowercase.txt:1:"); // fzf result row for the match
    await tmux.sendRaw("Enter");
    await tmux.waitFor(`${TEST_DIR}/lowercase.txt`);
  }, 15000);

  it("should navigate to selected file in subdirectory", async () => {
    await startYazi();
    await tmux.sendRaw("S");
    await tmux.sendLiteral("nested");
    await tmux.waitFor("subdir/nested.txt:1:");
    await tmux.sendRaw("Enter");
    await tmux.waitFor(`${TEST_DIR}/subdir/nested.txt`);
  }, 15000);
});
