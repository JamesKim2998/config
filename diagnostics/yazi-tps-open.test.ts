/**
 * yazi .tps file open menu tests
 * Tests that 'O' shows the Open menu for .tps files (TexturePacker)
 *
 * Expected behavior:
 * - 'l' opens .tps file in $EDITOR (edit opener)
 * - 'O' shows menu with both "edit" and "open" options
 *
 * Run: bun test yazi-tps-open.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { $ } from "bun";
import { TmuxRunner } from "./lib";

const TEST_DIR = "/tmp/yazi-tps-test";
const tmux = new TmuxRunner("yazi-tps-test");

beforeAll(async () => {
  await Bun.write(
    `${TEST_DIR}/test.tps`,
    `<?xml version="1.0"?><data><key>test</key></data>`,
  );
}, 10000);

afterAll(async () => {
  await tmux.kill();
  await $`rm -rf ${TEST_DIR}`.nothrow();
});

describe("yazi .tps file open menu", () => {
  it("should show both 'edit' and 'open' options for .tps files", async () => {
    await tmux.start({ cmd: "yazi", cwd: TEST_DIR });
    await tmux.waitFor("test.tps"); // file row visible ⇒ UI ready
    await tmux.sendRaw("O");
    const output = await tmux.waitFor("$EDITOR");
    expect(output).toContain("$EDITOR");
    expect(output).toContain("Open");
  }, 15000);
});
