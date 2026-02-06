/**
 * vim-kitty-navigator floating window tests
 * Verifies C-h/j/k/l don't move focus away from floating windows (Lazy, Snacks, etc.)
 * Run: bun test nvim-kitty-navigator.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { NvimRunner, NeovimClient } from "./lib";
import path from "path";

const FIXTURES_DIR = path.join(import.meta.dir, "fixtures");
const TEST_FILE = path.join(FIXTURES_DIR, "sample.txt");
const SOCKET_PATH = "/tmp/nvim-kitty-nav.sock";

const nvim = new NvimRunner();
let client: NeovimClient;

beforeAll(async () => {
  client = await nvim.start(SOCKET_PATH, TEST_FILE, FIXTURES_DIR);
  await Bun.sleep(500);
}, 15000);

afterAll(async () => {
  nvim.kill();
});

async function currentWinIsFloat(): Promise<boolean> {
  return (await client.call("luaeval", [
    "vim.api.nvim_win_get_config(0).relative ~= ''",
  ])) as boolean;
}

async function openFloat(): Promise<void> {
  await client.call("luaeval", [
    "(function() local buf = vim.api.nvim_create_buf(false, true) vim.api.nvim_open_win(buf, true, { relative = 'editor', width = 40, height = 10, row = 5, col = 5 }) end)()",
  ]);
  await Bun.sleep(300);
}

async function closeAllFloats(): Promise<void> {
  await client.call("luaeval", [
    "(function() for _, w in ipairs(vim.api.nvim_list_wins()) do if vim.api.nvim_win_get_config(w).relative ~= '' then pcall(vim.api.nvim_win_close, w, true) end end end)()",
  ]);
  await Bun.sleep(200);
}

describe("kitty-navigator with floating windows", () => {
  it("C-h should not escape floating window", async () => {
    await openFloat();
    expect(await currentWinIsFloat()).toBe(true);

    await client.input("<C-h>");
    await Bun.sleep(300);

    expect(await currentWinIsFloat()).toBe(true);
    await closeAllFloats();
  });

  it("C-j should not escape floating window", async () => {
    await openFloat();
    expect(await currentWinIsFloat()).toBe(true);

    await client.input("<C-j>");
    await Bun.sleep(300);

    expect(await currentWinIsFloat()).toBe(true);
    await closeAllFloats();
  });

  it("C-k should not escape floating window", async () => {
    await openFloat();
    expect(await currentWinIsFloat()).toBe(true);

    await client.input("<C-k>");
    await Bun.sleep(300);

    expect(await currentWinIsFloat()).toBe(true);
    await closeAllFloats();
  });

  it("C-l should not escape floating window", async () => {
    await openFloat();
    expect(await currentWinIsFloat()).toBe(true);

    await client.input("<C-l>");
    await Bun.sleep(300);

    expect(await currentWinIsFloat()).toBe(true);
    await closeAllFloats();
  });
});
