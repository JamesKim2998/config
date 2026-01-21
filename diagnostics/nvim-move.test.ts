/**
 * nvim move.nvim plugin tests
 * Run: bun test nvim-move.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { NvimRunner, NeovimClient } from "./lib";

const TEST_FILE = "/tmp/nvim-move-test.txt";
const SOCKET_PATH = "/tmp/nvim-move.sock";

const nvim = new NvimRunner();
let client: NeovimClient;

beforeAll(async () => {
  await Bun.write(TEST_FILE, "line1\nline2\nline3\nline4\nline5\n");
  client = await nvim.start(SOCKET_PATH, TEST_FILE);
}, 15000);

afterAll(async () => {
  await nvim.cleanup(TEST_FILE);
});

async function reload(content: string) {
  await nvim.reloadContent(TEST_FILE, content);
}

async function typeKeys(...keys: string[]) {
  for (const k of keys) {
    await client.input(k);
    await Bun.sleep(150);
  }
}

// --- Tests ---

describe("Alt+j/k mappings exist", () => {
  it("has normal mode mapping for <M-j>", async () => {
    const output = await client.commandOutput("verbose nmap <M-j>");
    expect(output).toContain("Move line down");
  });

  it("has normal mode mapping for <M-k>", async () => {
    const output = await client.commandOutput("verbose nmap <M-k>");
    expect(output).toContain("Move line up");
  });

  it("has visual mode mapping for <M-j>", async () => {
    const output = await client.commandOutput("verbose vmap <M-j>");
    expect(output).toContain("Move block down");
  });

  it("has visual mode mapping for <M-k>", async () => {
    const output = await client.commandOutput("verbose vmap <M-k>");
    expect(output).toContain("Move block up");
  });
});

describe("normal mode: <M-j> moves line down", () => {
  it("moves current line down", async () => {
    await reload("line1\nline2\nline3\n");
    await client.command("1");
    await typeKeys("<M-j>");

    const lines = await nvim.getLines();
    expect(lines[0]).toBe("line2");
    expect(lines[1]).toBe("line1");
  });

  it("moves multiple times", async () => {
    await reload("line1\nline2\nline3\nline4\n");
    await client.command("1");
    await typeKeys("<M-j>", "<M-j>");

    const lines = await nvim.getLines();
    expect(lines[0]).toBe("line2");
    expect(lines[1]).toBe("line3");
    expect(lines[2]).toBe("line1");
  });
});

describe("normal mode: <M-k> moves line up", () => {
  it("moves current line up", async () => {
    await reload("line1\nline2\nline3\n");
    await client.command("2");
    await typeKeys("<M-k>");

    const lines = await nvim.getLines();
    expect(lines[0]).toBe("line2");
    expect(lines[1]).toBe("line1");
  });
});

describe("visual mode: <M-j> moves block down", () => {
  it("moves selected lines down", async () => {
    await reload("line1\nline2\nline3\nline4\n");
    // Select lines 1-2 and move down using range command
    await client.command("1,2MoveBlock(1)");
    await Bun.sleep(200);

    const lines = await nvim.getLines();
    expect(lines[0]).toBe("line3");
    expect(lines[1]).toBe("line1");
    expect(lines[2]).toBe("line2");
  });
});

describe("visual mode: <M-k> moves block up", () => {
  it("moves selected lines up", async () => {
    await reload("line1\nline2\nline3\nline4\n");
    // Select lines 3-4 and move up using range command
    await client.command("3,4MoveBlock(-1)");
    await Bun.sleep(200);

    const lines = await nvim.getLines();
    expect(lines[0]).toBe("line1");
    expect(lines[1]).toBe("line3");
    expect(lines[2]).toBe("line4");
    expect(lines[3]).toBe("line2");
  });
});
