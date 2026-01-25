/**
 * nvim diffview keybinding tests
 * Run: bun test nvim-diffview.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { NvimRunner, NeovimClient } from "./lib";
import path from "path";

const FIXTURES_DIR = path.join(import.meta.dir, "fixtures");
const TEST_FILE = path.join(FIXTURES_DIR, "sample.txt");
const SOCKET_PATH = "/tmp/nvim-diffview.sock";

const nvim = new NvimRunner();
let client: NeovimClient;

beforeAll(async () => {
  client = await nvim.start(SOCKET_PATH, TEST_FILE, FIXTURES_DIR);
  await Bun.sleep(500);
}, 15000);

afterAll(async () => {
  nvim.kill();
});

describe("diffview file_history_panel", () => {
  it("Y copies absolute path", async () => {
    // Clear clipboard first
    await client.call("luaeval", ['vim.fn.setreg("+", "")']);

    // Open diffview file history for current file
    await client.command("DiffviewFileHistory %");
    await Bun.sleep(1000);

    // Verify diffview opened
    const wins = (await client.call("luaeval", ["vim.api.nvim_list_wins()"])) as number[];
    expect(wins.length).toBeGreaterThan(1);

    // Find and focus the DiffviewFileHistory panel (usually first window)
    for (const w of wins) {
      const ft = await client.call("luaeval", [`vim.bo[vim.api.nvim_win_get_buf(${w})].filetype`]);
      if (ft === "DiffviewFileHistory") {
        await client.call("luaeval", [`vim.api.nvim_set_current_win(${w})`]);
        break;
      }
    }
    await Bun.sleep(200);

    // Navigate to first entry (j to move down to actual file entry)
    await client.input("j");
    await Bun.sleep(100);

    // Press Y to copy path
    await client.input("Y");
    await Bun.sleep(500);

    const clipboard = (await client.call("luaeval", ['vim.fn.getreg("+")'])) as string;

    // Close diffview
    await client.command("DiffviewClose");
    await Bun.sleep(300);

    // Should contain the test file path (or at least be a valid path)
    expect(clipboard).toContain("sample.txt");
  });
});

describe("diffview keymaps", () => {
  it("q closes diffview and goes to viewed file", async () => {
    await client.command("DiffviewFileHistory %");
    await Bun.sleep(800);

    // Verify opened
    const winsBefore = (await client.call("luaeval", ["vim.api.nvim_list_wins()"])) as number[];
    expect(winsBefore.length).toBeGreaterThan(1);

    // Focus file history panel and press q to close
    for (const w of winsBefore) {
      const ft = await client.call("luaeval", [`vim.bo[vim.api.nvim_win_get_buf(${w})].filetype`]);
      if (ft === "DiffviewFileHistory") {
        await client.call("luaeval", [`vim.api.nvim_set_current_win(${w})`]);
        break;
      }
    }
    await Bun.sleep(100);
    await client.input("q");
    await Bun.sleep(500);

    // Verify closed and jumped to file
    const winsAfter = (await client.call("luaeval", ["vim.api.nvim_list_wins()"])) as number[];
    expect(winsAfter.length).toBe(1);

    // Should be at the sample.txt file
    const currentFile = (await client.call("luaeval", ["vim.fn.expand('%:t')"])) as string;
    expect(currentFile).toBe("sample.txt");
  });
});
