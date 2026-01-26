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
import { TmuxRunner } from "./lib";

const TEST_DIR = "/tmp/yazi-tps-test";
const tmux = new TmuxRunner("yazi-tps-test", TEST_DIR);

beforeAll(async () => {
  await Bun.write(
    `${TEST_DIR}/test.tps`,
    `<?xml version="1.0"?><data><key>test</key></data>`,
  );
}, 10000);

afterAll(() => tmux.cleanup());

describe("yazi .tps file open menu", () => {
  it("should show both 'edit' and 'open' options for .tps files", async () => {
    await tmux.startYazi();
    await tmux.sendRaw("O", 500);

    const output = await tmux.capture();
    console.log("=== Open menu ===\n" + output);

    expect(output).toContain("$EDITOR");
    expect(output).toContain("Open");

    await tmux.kill();
  }, 15000);
});
