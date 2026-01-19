/**
 * nvim markdown list continuation tests
 * Run: bun test nvim-markdown-lists.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { NvimRunner, NeovimClient } from "./lib";

const TEST_FILE = "/tmp/nvim-diag-test.md";
const SOCKET_PATH = "/tmp/nvim-diag.sock";

const nvim = new NvimRunner();
let client: NeovimClient;

beforeAll(async () => {
  await Bun.write(TEST_FILE, "# Test\n");
  client = await nvim.start(SOCKET_PATH, TEST_FILE);
  await nvim.setFiletype("markdown");
}, 15000);

afterAll(async () => {
  await nvim.cleanup(TEST_FILE);
});

// --- Helpers ---

async function reload(content: string) {
  await nvim.reloadContent(TEST_FILE, content);
}

async function typeKeys(...keys: string[]) {
  for (const k of keys) {
    await client.input(k);
    await Bun.sleep(k === "<CR>" ? 300 : 200);
  }
}

async function getLine(n: number): Promise<string> {
  const lines = await nvim.getLines();
  return lines[n] ?? "";
}

// --- Tests ---

describe("markdown-lists mapping", () => {
  it("'o' has list mapping", async () => {
    const output = await client.commandOutput("verbose nmap o");
    expect(output).toContain("markdown-lists");
  });
});

describe("'o' inserts below with prefix", () => {
  const cases = [
    { name: "todo", content: "- [ ] todo item", expect: /^- \[ \] new$/ },
    { name: "bullet -", content: "- bullet item", expect: /^- new$/ },
    { name: "bullet *", content: "* bullet item", expect: /^\* new$/ },
    { name: "numbered 1.", content: "1. first item", expect: /^2\. new$/ },
    { name: "numbered 5.", content: "5. fifth item", expect: /^6\. new$/ },
    { name: "numbered 1)", content: "1) first item", expect: /^2\) new$/ },
    { name: "blockquote", content: "> blockquote", expect: /^> new$/ },
    { name: "indented bullet", content: "    - indented", expect: /^    - new$/ },
    { name: "indented blockquote", content: "    > indented", expect: /^    > new$/ },
  ];

  for (const { name, content, expect: pattern } of cases) {
    it(name, async () => {
      await reload(`# Test\n\n${content}\n`);
      await client.command("3");
      await typeKeys("o", "new", "<Esc>");
      expect(await getLine(3)).toMatch(pattern);
    });
  }
});

describe("'O' inserts above with prefix", () => {
  const cases = [
    { name: "todo", content: "- [ ] todo item", expect: /^- \[ \] new$/ },
    { name: "bullet", content: "- bullet item", expect: /^- new$/ },
    { name: "numbered", content: "2. second item", expect: /^2\. new$/ },
    { name: "blockquote", content: "> blockquote", expect: /^> new$/ },
    { name: "indented blockquote", content: "    > indented", expect: /^    > new$/ },
  ];

  for (const { name, content, expect: pattern } of cases) {
    it(name, async () => {
      await reload(`# Test\n\n${content}\n`);
      await client.command("3");
      await typeKeys("O", "new", "<Esc>");
      expect(await getLine(2)).toMatch(pattern);
    });
  }
});

describe("<leader>tt toggle", () => {
  it("toggles [ ] to [x]", async () => {
    await reload("# Test\n\n- [ ] todo\n");
    await client.command("3");
    await typeKeys("<Space>tt");
    expect(await getLine(2)).toContain("[x]");
  });

  it("toggles [x] to [ ]", async () => {
    await reload("# Test\n\n- [x] done\n");
    await client.command("3");
    await typeKeys("<Space>tt");
    expect(await getLine(2)).toContain("[ ]");
  });
});

describe("<CR> continues list", () => {
  it("continues todo item", async () => {
    await reload("# Test\n\n- [ ] todo\n");
    await client.command("3");
    await typeKeys("A", "<CR>", "new", "<Esc>");
    expect(await getLine(3)).toMatch(/^- \[ \] new$/);
  });
});

describe("renumbering", () => {
  const numbered = "# Test\n\n1. first\n2. second\n3. third\n";
  const expected = ["1. first", "2. inserted", "3. second", "4. third"];

  it("'o' renumbers below", async () => {
    await reload(numbered);
    await client.command("3");
    await typeKeys("o", "inserted", "<Esc>");
    const lines = await nvim.getLines();
    expect(lines.slice(2, 6)).toEqual(expected);
  });

  it("'O' renumbers below", async () => {
    await reload(numbered);
    await client.command("4");
    await typeKeys("O", "inserted", "<Esc>");
    const lines = await nvim.getLines();
    expect(lines.slice(2, 6)).toEqual(expected);
  });

  it("<CR> renumbers below", async () => {
    await reload(numbered);
    await client.command("3");
    await typeKeys("A", "<CR>", "inserted", "<Esc>");
    const lines = await nvim.getLines();
    expect(lines.slice(2, 6)).toEqual(expected);
  });
});

describe("]<Space> inserts empty item below", () => {
  it("todo item (stays in normal mode)", async () => {
    await reload("# Test\n\n- [ ] todo\n");
    await client.command("3");
    await typeKeys("]<Space>");
    const line = await getLine(3);
    const mode = await client.call("mode") as string;
    expect(line).toBe("- [ ] ");
    expect(mode).toBe("n");
  });

  it("bullet item", async () => {
    await reload("# Test\n\n- bullet\n");
    await client.command("3");
    await typeKeys("]<Space>");
    expect(await getLine(3)).toBe("- ");
  });

  it("numbered item", async () => {
    await reload("# Test\n\n1. first\n");
    await client.command("3");
    await typeKeys("]<Space>");
    expect(await getLine(3)).toBe("2. ");
  });
});

describe("[<Space> inserts empty item above", () => {
  it("todo item (stays in normal mode)", async () => {
    await reload("# Test\n\n- [ ] todo\n");
    await client.command("3");
    await typeKeys("[<Space>");
    const line = await getLine(2);
    const mode = await client.call("mode") as string;
    expect(line).toBe("- [ ] ");
    expect(mode).toBe("n");
  });

  it("bullet item", async () => {
    await reload("# Test\n\n- bullet\n");
    await client.command("3");
    await typeKeys("[<Space>");
    expect(await getLine(2)).toBe("- ");
  });

  it("numbered item", async () => {
    await reload("# Test\n\n2. second\n");
    await client.command("3");
    await typeKeys("[<Space>");
    expect(await getLine(2)).toBe("2. ");
  });
});

describe("buffer integrity", () => {
  it("buffer not modified after reload", async () => {
    await reload("# Test\n\n- [ ] todo\n");
    const modified = await client.eval("&modified");
    expect(modified).toBe(0);
  });
});
