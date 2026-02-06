/**
 * vim-kitty-navigator tests
 *
 * Rule: any float visible → C-hjkl dispatches to kitty (not vim splits).
 * Covers: focused floats (Lazy), unfocused floats (Snacks notifier),
 *         cmdline mode with float (Noice), and normal split navigation.
 *
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

async function currentWinId(): Promise<number> {
  return (await client.call("luaeval", ["vim.api.nvim_get_current_win()"])) as number;
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

/** Spy on vim.fn.system — capture only, do NOT execute */
async function installSystemSpy(): Promise<void> {
  await client.call("luaeval", [
    "(function() _G._kitty_nav_calls = {} local orig = vim.fn.system _G._kitty_nav_orig_system = orig vim.fn.system = function(cmd) table.insert(_G._kitty_nav_calls, cmd) return '' end end)()",
  ]);
}

async function getSystemCalls(): Promise<string[]> {
  const calls = (await client.call("luaeval", ["_G._kitty_nav_calls"])) as string[];
  await client.call("luaeval", [
    "(function() if _G._kitty_nav_orig_system then vim.fn.system = _G._kitty_nav_orig_system end _G._kitty_nav_calls = nil _G._kitty_nav_orig_system = nil end)()",
  ]);
  return calls ?? [];
}

function kittyCallsFrom(calls: string[]): string[] {
  return calls.filter((c: string) => c.includes("kitty @ focus-window"));
}

async function ensureCleanState(): Promise<void> {
  await client.input("<Esc>");
  await Bun.sleep(100);
  await client.input("<Esc>");
  await Bun.sleep(100);
  await client.call("luaeval", [
    "(function() if _G._kitty_nav_orig_system then vim.fn.system = _G._kitty_nav_orig_system _G._kitty_nav_calls = nil _G._kitty_nav_orig_system = nil end end)()",
  ]);
  await closeAllFloats();
}

// ---------------------------------------------------------------------------
// 1. No floats: C-hjkl navigates vim splits
// ---------------------------------------------------------------------------
describe("no floats: C-hjkl navigates vim splits", () => {
  it("C-l moves to right split", async () => {
    await client.command("vsplit");
    await Bun.sleep(200);
    await client.command("wincmd h");
    await Bun.sleep(100);
    const before = await currentWinId();

    await client.input("<C-l>");
    await Bun.sleep(300);

    expect(await currentWinId()).not.toBe(before);
    await client.command("only");
    await Bun.sleep(200);
  });

  it("C-h moves to left split", async () => {
    await client.command("vsplit");
    await Bun.sleep(200);
    await client.command("wincmd l");
    await Bun.sleep(100);
    const before = await currentWinId();

    await client.input("<C-h>");
    await Bun.sleep(300);

    expect(await currentWinId()).not.toBe(before);
    await client.command("only");
    await Bun.sleep(200);
  });

  it("C-j moves to bottom split", async () => {
    await client.command("split");
    await Bun.sleep(200);
    await client.command("wincmd k");
    await Bun.sleep(100);
    const before = await currentWinId();

    await client.input("<C-j>");
    await Bun.sleep(300);

    expect(await currentWinId()).not.toBe(before);
    await client.command("only");
    await Bun.sleep(200);
  });

  it("C-k moves to top split", async () => {
    await client.command("split");
    await Bun.sleep(200);
    await client.command("wincmd j");
    await Bun.sleep(100);
    const before = await currentWinId();

    await client.input("<C-k>");
    await Bun.sleep(300);

    expect(await currentWinId()).not.toBe(before);
    await client.command("only");
    await Bun.sleep(200);
  });

  it("does not dispatch kitty when split exists", async () => {
    await client.command("vsplit");
    await Bun.sleep(200);
    await client.command("wincmd h");
    await Bun.sleep(100);
    await installSystemSpy();

    await client.input("<C-l>");
    await Bun.sleep(300);

    expect(kittyCallsFrom(await getSystemCalls())).toHaveLength(0);
    await client.command("only");
    await Bun.sleep(200);
  });
});

// ---------------------------------------------------------------------------
// 2. Focused float (e.g. Lazy UI): C-hjkl dispatches kitty
// ---------------------------------------------------------------------------
describe("focused float: C-hjkl dispatches kitty", () => {
  for (const [key, dir] of [
    ["<C-h>", "left"],
    ["<C-j>", "bottom"],
    ["<C-k>", "top"],
    ["<C-l>", "right"],
  ] as const) {
    it(`${key} dispatches kitty neighbor:${dir}`, async () => {
      await openFloat();
      await installSystemSpy();

      await client.input(key);
      await Bun.sleep(300);

      const calls = await getSystemCalls();
      expect(calls).toContainEqual(`kitty @ focus-window --match neighbor:${dir}`);
      await closeAllFloats();
    });
  }
});

// ---------------------------------------------------------------------------
// 3. Unfocused float (e.g. Snacks notifier): C-hjkl dispatches kitty
//    Cursor is in the editor, but a notification float is visible.
// ---------------------------------------------------------------------------
describe("unfocused float (snacks notifier): C-hjkl dispatches kitty", () => {
  for (const [key, dir] of [
    ["<C-h>", "left"],
    ["<C-j>", "bottom"],
    ["<C-k>", "top"],
    ["<C-l>", "right"],
  ] as const) {
    it(`${key} dispatches kitty neighbor:${dir}`, async () => {
      // Trigger a snacks notification (creates unfocused float)
      await client.call("luaeval", ['vim.notify("test", vim.log.levels.INFO)']);
      await Bun.sleep(500);
      await installSystemSpy();

      await client.input(key);
      await Bun.sleep(300);

      const calls = await getSystemCalls();
      expect(calls).toContainEqual(`kitty @ focus-window --match neighbor:${dir}`);
      await closeAllFloats();
    });
  }
});

// ---------------------------------------------------------------------------
// 4. Cmdline mode with float (e.g. Noice): C-hjkl dispatches kitty
//    Simulated: open float, then enter ":" cmdline.
// ---------------------------------------------------------------------------
describe("cmdline mode with float: C-hjkl dispatches kitty", () => {
  for (const [key, dir] of [
    ["<C-h>", "left"],
    ["<C-l>", "right"],
  ] as const) {
    it(`${key} dispatches kitty neighbor:${dir}`, async () => {
      await openFloat();
      await installSystemSpy();

      await client.input(":");
      await Bun.sleep(300);

      await client.input(key);
      await Bun.sleep(300);

      await client.input("<Esc>");
      await Bun.sleep(300);

      const calls = await getSystemCalls();
      expect(kittyCallsFrom(calls)).toContainEqual(
        `kitty @ focus-window --match neighbor:${dir}`,
      );
      await closeAllFloats();
    });
  }

  it("C-h preserves backspace in plain cmdline (no float)", async () => {
    await ensureCleanState();
    await installSystemSpy();

    await client.input(":abc");
    await Bun.sleep(300);
    await client.input("<C-h>");
    await Bun.sleep(300);

    const cmdline = (await client.call("luaeval", ["vim.fn.getcmdline()"])) as string;
    await client.input("<Esc>");
    await Bun.sleep(300);

    expect(kittyCallsFrom(await getSystemCalls())).toHaveLength(0);
    expect(cmdline).toBe("ab");
  });
});

// ---------------------------------------------------------------------------
// 5. Insert mode with float: C-hjkl dispatches kitty
// ---------------------------------------------------------------------------
describe("insert mode with float: C-hjkl dispatches kitty", () => {
  for (const [key, dir] of [
    ["<C-h>", "left"],
    ["<C-j>", "bottom"],
    ["<C-k>", "top"],
    ["<C-l>", "right"],
  ] as const) {
    it(`${key} dispatches kitty neighbor:${dir}`, async () => {
      await client.call("luaeval", ['vim.notify("test", vim.log.levels.INFO)']);
      await Bun.sleep(500);

      await client.input("i");
      await Bun.sleep(100);
      await installSystemSpy();

      await client.input(key);
      await Bun.sleep(300);

      await client.input("<Esc>");
      await Bun.sleep(200);

      const calls = await getSystemCalls();
      expect(calls).toContainEqual(`kitty @ focus-window --match neighbor:${dir}`);
      await closeAllFloats();
    });
  }

  it("C-h preserves backspace in insert mode (no float)", async () => {
    await ensureCleanState();

    await client.input("i");
    await Bun.sleep(100);
    await client.input("abc");
    await Bun.sleep(100);
    await installSystemSpy();

    await client.input("<C-h>");
    await Bun.sleep(300);

    await client.input("<Esc>");
    await Bun.sleep(200);

    expect(kittyCallsFrom(await getSystemCalls())).toHaveLength(0);
    // Undo to restore file
    await client.input("u");
    await Bun.sleep(200);
  });
});
