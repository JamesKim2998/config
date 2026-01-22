/**
 * nvim neo-tree keybinding tests
 * Run: bun test nvim-neo-tree.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { NvimRunner, NeovimClient } from "./lib";
import path from "path";

const FIXTURES_DIR = path.join(import.meta.dir, "fixtures");
const TEST_FILE = path.join(FIXTURES_DIR, "sample.txt");
const SOCKET_PATH = "/tmp/nvim-neo-tree.sock";

const nvim = new NvimRunner();
let client: NeovimClient;

beforeAll(async () => {
  client = await nvim.start(SOCKET_PATH, TEST_FILE, FIXTURES_DIR);
  await Bun.sleep(500);
}, 15000);

afterAll(async () => {
  nvim.kill();
});

describe("neo-tree", () => {
  it("<C-n> toggles explorer", async () => {
    // Open neo-tree
    await client.input("<C-n>");
    await Bun.sleep(500);

    const wins = (await client.call("luaeval", ["vim.api.nvim_list_wins()"])) as number[];
    expect(wins.length).toBeGreaterThan(1);

    // Check neo-tree filetype
    const fts = await Promise.all(
      wins.map((w) => client.call("luaeval", [`vim.bo[vim.api.nvim_win_get_buf(${w})].filetype`]))
    );
    expect(fts).toContain("neo-tree");

    // Close neo-tree
    await client.input("<C-n>");
    await Bun.sleep(300);

    const winsAfter = (await client.call("luaeval", ["vim.api.nvim_list_wins()"])) as number[];
    expect(winsAfter.length).toBe(1);
  });

  it("Y copies absolute path", async () => {
    await client.input("<C-n>");
    await Bun.sleep(500);

    // Navigate to sample.txt and copy path
    await client.input("/sample<CR>");
    await Bun.sleep(300);
    await client.input("Y");
    await Bun.sleep(300);

    const clipboard = await client.call("luaeval", ['vim.fn.getreg("+")']);
    await client.input("<C-n>");
    await Bun.sleep(100);

    expect(clipboard).toBe(TEST_FILE);
  });

  // Note: [g and ]g are neo-tree internal mappings (not vim keymaps)
  // They should work when pressed in neo-tree filesystem view with git changes
  // Manual test: open neo-tree, modify a file, press ]g to jump to it
});

describe("buffer close", () => {
  it("qq closes buffer immediately", async () => {
    // Ensure we start with the original buffer
    await client.command("e! " + TEST_FILE);
    await Bun.sleep(200);

    // Open a second buffer
    await client.command("e " + path.join(FIXTURES_DIR, "another.txt"));
    await Bun.sleep(200);

    const bufsBefore = (await client.call("luaeval", [
      "vim.tbl_filter(function(b) return vim.bo[b].buflisted end, vim.api.nvim_list_bufs())",
    ])) as number[];

    // Verify we have 2 buffers before closing
    expect(bufsBefore.length).toBe(2);

    // Close with qq
    await client.input("qq");
    await Bun.sleep(500);

    const bufsAfter = (await client.call("luaeval", [
      "vim.tbl_filter(function(b) return vim.bo[b].buflisted end, vim.api.nvim_list_bufs())",
    ])) as number[];

    expect(bufsAfter.length).toBe(1);
  });
});
