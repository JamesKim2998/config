/**
 * nvim readline-style keymaps E2E tests
 * Tests Ctrl+A (home) and Ctrl+E (end) in insert and command mode
 * Run: bun test nvim-readline.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { NvimRunner, NeovimClient } from "./lib";

const SOCKET_PATH = "/tmp/nvim-readline.sock";
const TEST_FILE = "/tmp/nvim-readline-test.txt";

const nvim = new NvimRunner();
let client: NeovimClient;

beforeAll(async () => {
  await Bun.write(TEST_FILE, "hello world");
  client = await nvim.start(SOCKET_PATH, TEST_FILE);
  await Bun.sleep(1000);
}, 20000);

afterAll(async () => {
  await nvim.cleanup(TEST_FILE);
});

describe("readline keymaps in insert mode", () => {
  it("Ctrl+A moves cursor to beginning of line", async () => {
    // Go to end of line, enter insert mode, press Ctrl+A
    await client.command("normal! $");
    await client.input("a"); // append mode (cursor at end)
    await Bun.sleep(100);
    await client.input("<C-a>");
    await Bun.sleep(100);

    const col = await client.call("col", ["."])as number;
    await client.input("<Esc>");

    expect(col).toBe(1);
  });

  it("Ctrl+E moves cursor to end of line", async () => {
    // Go to beginning, enter insert mode, press Ctrl+E
    await client.command("normal! 0");
    await client.input("i"); // insert mode (cursor at beginning)
    await Bun.sleep(100);
    await client.input("<C-e>");
    await Bun.sleep(100);

    const col = await client.call("col", ["."])as number;
    const lineLen = await client.call("col", ["$"])as number;
    await client.input("<Esc>");

    expect(col).toBe(lineLen);
  });
});

describe("readline keymaps in command mode", () => {
  it("Ctrl+A moves cursor to beginning in command line", async () => {
    // Enter command mode with some text, press Ctrl+A, check cursor pos
    await client.input(":");
    await Bun.sleep(50);
    await client.input("echo hello");
    await Bun.sleep(50);
    await client.input("<C-a>");
    await Bun.sleep(50);

    const cmdPos = await client.call("getcmdpos", [])as number;
    await client.input("<Esc>");

    expect(cmdPos).toBe(1);
  });

  it("Ctrl+E moves cursor to end in command line", async () => {
    // Enter command mode, go to start, press Ctrl+E
    await client.input(":");
    await Bun.sleep(50);
    await client.input("echo hello");
    await Bun.sleep(50);
    await client.input("<C-a>"); // go to start first
    await Bun.sleep(50);
    await client.input("<C-e>");
    await Bun.sleep(50);

    const cmdPos = await client.call("getcmdpos", [])as number;
    const cmdLen = (await client.call("getcmdline", [])as string).length;
    await client.input("<Esc>");

    // Cursor should be after last char (cmdLen + 1)
    expect(cmdPos).toBe(cmdLen + 1);
  });
});
