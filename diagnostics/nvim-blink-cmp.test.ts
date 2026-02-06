/**
 * blink.cmp completion tests
 * Verifies LSP and minuet sources are registered and completions work
 * Run: bun test nvim-blink-cmp.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { NvimRunner, NeovimClient } from "./lib";

const SOCKET_PATH = "/tmp/nvim-blink-cmp.sock";
const TEST_FILE = "/tmp/blink-cmp-test.lua";

const nvim = new NvimRunner();
let client: NeovimClient;

beforeAll(async () => {
  await Bun.write(TEST_FILE, "local x = vim.api.\n");
  client = await nvim.start(SOCKET_PATH, TEST_FILE);
  await nvim.setFiletype("lua");
  await Bun.sleep(500);
  // Trigger InsertEnter so blink.cmp loads (lazy-loaded on InsertEnter)
  await client.input("i<Esc>");
  await Bun.sleep(1000);
}, 15000);

afterAll(async () => {
  await nvim.cleanup(TEST_FILE);
});

describe("blink.cmp", () => {
  it("blink.cmp is loaded", async () => {
    const loaded = await client.call("luaeval", [
      "package.loaded['blink.cmp'] ~= nil",
    ]);
    expect(loaded).toBe(true);
  });

  it("minuet plugin is loaded", async () => {
    const loaded = await client.call("luaeval", [
      "package.loaded['minuet'] ~= nil",
    ]);
    expect(loaded).toBe(true);
  });

  it("super-tab keymap is active", async () => {
    const maps = await client.commandOutput("imap <Tab>");
    expect(maps).toMatch(/blink/i);
  });

  it("Alt-y keymap is active", async () => {
    const maps = await client.commandOutput("imap <A-y>");
    expect(maps).toMatch(/blink|minuet/i);
  });
});

describe("minuet gemini", () => {
  it("gemini provider is configured", async () => {
    const provider = await client.call("luaeval", [
      "require('minuet').config.provider",
    ]);
    expect(provider).toBe("gemini");
  });

  it("gemini model is gemini-3-flash-preview", async () => {
    const model = await client.call("luaeval", [
      "require('minuet').config.provider_options.gemini.model",
    ]);
    expect(model).toBe("gemini-3-flash-preview");
  });

  it("thinkingBudget is disabled", async () => {
    const budget = await client.call("luaeval", [
      "require('minuet').config.provider_options.gemini.optional.generationConfig.thinkingConfig.thinkingBudget",
    ]);
    expect(budget).toBe(0);
  });

  it("API key is available", async () => {
    const hasKey = await client.call("luaeval", [
      "require('minuet.utils').get_api_key(require('minuet').config.provider_options.gemini.api_key) ~= nil",
    ]);
    expect(hasKey).toBe(true);
  });

  it("virtualtext is enabled for all filetypes", async () => {
    const ft = await client.call("luaeval", [
      "require('minuet').config.virtualtext.auto_trigger_ft",
    ]);
    expect(ft).toEqual(["*"]);
  });
});
