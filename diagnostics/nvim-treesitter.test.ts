/**
 * nvim-treesitter plugin E2E tests
 * Run: bun test nvim-treesitter.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { NvimRunner, NeovimClient } from "./lib";

const SOCKET_PATH = "/tmp/nvim-treesitter.sock";
const TEST_FILE = "/tmp/nvim-ts-test.json";

const nvim = new NvimRunner();
let client: NeovimClient;

beforeAll(async () => {
  await Bun.write(TEST_FILE, '{"key": "value"}');
  client = await nvim.start(SOCKET_PATH, TEST_FILE);
  await Bun.sleep(2000); // Wait for plugins to load
}, 20000);

afterAll(async () => {
  await nvim.cleanup(TEST_FILE);
});

describe("nvim-treesitter plugin", () => {
  it("main module loads", async () => {
    const ok = await client.call("luaeval", [
      "pcall(require, 'nvim-treesitter')"
    ]) as boolean;
    expect(ok).toBe(true);
  });

  it("setup function exists", async () => {
    const hasSetup = await client.call("luaeval", [
      "type(require('nvim-treesitter').setup) == 'function'"
    ]) as boolean;
    expect(hasSetup).toBe(true);
  });

  it("install function exists", async () => {
    const hasInstall = await client.call("luaeval", [
      "type(require('nvim-treesitter').install) == 'function'"
    ]) as boolean;
    expect(hasInstall).toBe(true);
  });

  it("json parser info available", async () => {
    const exists = await client.call("luaeval", [
      "require('nvim-treesitter.parsers').json ~= nil"
    ]) as boolean;
    expect(exists).toBe(true);
  });

  it("json parser is installed (compiled .so exists)", async () => {
    const installed = await client.call("luaeval", [
      "vim.tbl_contains(require('nvim-treesitter').get_installed(), 'json')"
    ]) as boolean;
    expect(installed).toBe(true);
  });

  it("typescript parser is installed", async () => {
    const installed = await client.call("luaeval", [
      "vim.tbl_contains(require('nvim-treesitter').get_installed(), 'typescript')"
    ]) as boolean;
    expect(installed).toBe(true);
  });

  it("tsx parser is installed", async () => {
    const installed = await client.call("luaeval", [
      "vim.tbl_contains(require('nvim-treesitter').get_installed(), 'tsx')"
    ]) as boolean;
    expect(installed).toBe(true);
  });
});
