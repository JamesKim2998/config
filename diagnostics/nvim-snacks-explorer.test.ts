/**
 * nvim snacks.nvim explorer copy path action tests
 * Run: bun test nvim-snacks-explorer.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { NvimRunner, NeovimClient, typeKeys } from "./lib";
import path from "path";

const FIXTURES_DIR = path.join(import.meta.dir, "fixtures");
const TEST_FILE = path.join(FIXTURES_DIR, "sample.txt");
const SOCKET_PATH = "/tmp/nvim-snacks.sock";

const nvim = new NvimRunner();
let client: NeovimClient;

beforeAll(async () => {
  client = await nvim.start(SOCKET_PATH, TEST_FILE, FIXTURES_DIR);
  await Bun.sleep(500);
}, 15000);

afterAll(async () => {
  nvim.kill();
});

describe("snacks explorer copy path", () => {
  it("y copies relative path", async () => {
    await client.command("lua Snacks.explorer()");
    await Bun.sleep(800);

    await client.input("y");
    await Bun.sleep(300);

    const clipboard = await client.call("luaeval", ['vim.fn.getreg("+")']);
    await client.input("q");
    await Bun.sleep(100);

    expect(clipboard).toBe("sample.txt");
  });

  it("Y copies absolute path", async () => {
    await client.command("lua Snacks.explorer()");
    await Bun.sleep(800);

    await client.input("Y");
    await Bun.sleep(300);

    const clipboard = await client.call("luaeval", ['vim.fn.getreg("+")']);
    await client.input("q");
    await Bun.sleep(100);

    expect(clipboard).toBe(TEST_FILE);
  });
});
