/**
 * nvim flash.nvim plugin tests
 * Run: bun test nvim-flash.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { NvimRunner, NeovimClient } from "./lib";

const TEST_FILE = "/tmp/nvim-flash-test.txt";
const SOCKET_PATH = "/tmp/nvim-flash.sock";

const nvim = new NvimRunner();
let client: NeovimClient;

beforeAll(async () => {
  await Bun.write(TEST_FILE, "first line\nsecond line\nthird line\nfourth line\nfifth line\n");
  client = await nvim.start(SOCKET_PATH, TEST_FILE);
}, 15000);

afterAll(async () => {
  await nvim.cleanup(TEST_FILE);
});

describe("flash.nvim mappings", () => {
  it("has 's' mapping for flash forward", async () => {
    const output = await client.commandOutput("verbose nmap s");
    expect(output).toContain("Flash");
  });

  it("has 'S' mapping for flash backward", async () => {
    const output = await client.commandOutput("verbose nmap S");
    expect(output).toContain("Flash Backward");
  });

  it("has 'r' mapping in operator-pending mode", async () => {
    const output = await client.commandOutput("verbose omap r");
    expect(output).toContain("Remote Flash");
  });

  it("has '<c-s>' mapping in command mode", async () => {
    const output = await client.commandOutput("verbose cmap <c-s>");
    expect(output).toContain("Toggle Flash Search");
  });
});

describe("flash.nvim visual mode mappings", () => {
  it("has 's' mapping in visual mode", async () => {
    const output = await client.commandOutput("verbose xmap s");
    expect(output).toContain("Flash");
  });

  it("has 'S' mapping in visual mode", async () => {
    const output = await client.commandOutput("verbose xmap S");
    expect(output).toContain("Flash Backward");
  });
});
