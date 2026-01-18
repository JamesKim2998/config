#!/usr/bin/env bun
/**
 * Diagnostic: nvim markdown list continuation
 *
 * Tests bullets.vim and checkmate.nvim using nvim remote API.
 * Usage: bun run nvim-markdown-lists.ts
 */

import { attach, NeovimClient } from "neovim";
import { spawn, ChildProcess } from "child_process";
import { check, header, section } from "./lib";

const TEST_FILE = "/tmp/nvim-diag-test.md";
const SOCKET_PATH = "/tmp/nvim-diag.sock";

const TEST_CONTENT = `# Test

- [ ] todo item
- bullet item
1. numbered item
> blockquote line
`;

let nvimProcess: ChildProcess | null = null;
let nvim: NeovimClient | null = null;

// --- Helpers ---

async function withTimeout<T>(promise: Promise<T>, ms: number, name: string): Promise<T> {
  return Promise.race([
    promise,
    new Promise<T>((_, reject) =>
      setTimeout(() => reject(new Error(`${name} timed out after ${ms}ms`)), ms)
    ),
  ]);
}

async function reloadFile(nvim: NeovimClient, content = TEST_CONTENT) {
  await Bun.write(TEST_FILE, content);
  await nvim.command("e!");
  await Bun.sleep(300);
}

async function getLines(nvim: NeovimClient): Promise<string[]> {
  const buf = await nvim.buffer;
  return await buf.getLines({ start: 0, end: -1, strictIndexing: false });
}

// Test helper: go to line, press key, optionally type text, get result line
async function testKey(
  nvim: NeovimClient,
  lineNum: number,
  key: string,
  typeText?: string
): Promise<string[]> {
  await nvim.command(String(lineNum));
  await nvim.input(key);
  await Bun.sleep(300);
  if (typeText) {
    await nvim.input(typeText);
    await nvim.input("<Esc>");
    await Bun.sleep(200);
  }
  return getLines(nvim);
}

// Check if line has checkbox (raw or rendered)
function hasCheckbox(line: string): boolean {
  return line.includes("- [ ]") || line.includes("- □");
}

// --- Setup/Cleanup ---

async function setup(): Promise<NeovimClient> {
  await Bun.$`rm -f ${SOCKET_PATH}`.nothrow();
  console.log("  Creating test file...");
  await Bun.write(TEST_FILE, TEST_CONTENT);

  console.log("  Starting nvim with socket...");
  nvimProcess = spawn("nvim", ["--headless", "--listen", SOCKET_PATH, "-n", TEST_FILE], {
    stdio: ["pipe", "pipe", "pipe"],
    detached: true,
  });
  nvimProcess.stderr?.on("data", (d) => console.log("  nvim stderr:", d.toString().trim()));

  console.log("  Waiting for socket...");
  for (let i = 0; i < 20; i++) {
    if (await Bun.file(SOCKET_PATH).exists()) break;
    await Bun.sleep(100);
  }

  console.log("  Connecting to socket...");
  nvim = await attach({ socket: SOCKET_PATH });
  console.log("  Connected to nvim");
  await Bun.sleep(300);

  console.log("  Loading plugins...");
  try {
    await nvim.command("Lazy load checkmate.nvim bullets.vim");
    console.log("  Plugins loaded via Lazy");
  } catch (e) {
    console.log("  Lazy load skipped:", String(e).slice(0, 50));
  }

  console.log("  Setting filetype...");
  await nvim.command("set filetype=markdown");
  await nvim.command("doautocmd FileType markdown");
  await Bun.sleep(100);
  await nvim.command("redraw");
  await Bun.sleep(300);

  console.log("  Setup complete");
  return nvim;
}

async function cleanup() {
  if (nvim) try { await nvim.command("qa!"); } catch {}
  if (nvimProcess) nvimProcess.kill();
  await Bun.$`rm -f ${TEST_FILE} ${SOCKET_PATH}`.nothrow();
}

// --- Tests ---

async function testMapping(nvim: NeovimClient): Promise<boolean> {
  const output = await nvim.commandOutput("verbose nmap o");
  // Check for custom mapping (markdown-lists, checkmate, or bullets)
  const hasMapping = output.includes("markdown-lists") || output.includes("checkmate") || output.includes("bullets");
  const source = output.includes("markdown-lists") ? "markdown-lists" :
    output.includes("checkmate") ? "checkmate" : output.includes("bullets") ? "bullets" : "none";
  return check("'o' has list mapping", hasMapping, source);
}

// Test 'o' creates checkbox on various line types
async function testOonTodo(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim);
  const lines = await testKey(nvim, 3, "o", "new todo");
  const line = lines[3] || "";
  const ok = hasCheckbox(line) && line.includes("new todo");
  return check("'o' on todo creates checkbox", ok, `line 4: "${line.trim()}"`);
}

async function testOonRendered(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim, `# Test\n\n- □ rendered todo\n- bullet item\n`);
  const lines = await testKey(nvim, 3, "o", "new from rendered");
  const line = lines[3] || "";
  const ok = hasCheckbox(line) && line.includes("new from rendered");
  return check("'o' on rendered checkbox", ok, `line 4: "${line.trim()}"`);
}

async function testOonChecked(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim, `# Test\n\n- ✔ checked item\n- bullet item\n`);
  const lines = await testKey(nvim, 3, "o", "new from checked");
  const line = lines[3] || "";
  const ok = hasCheckbox(line) && line.includes("new from checked");
  return check("'o' on checked (✔)", ok, `line 4: "${line.trim()}"`);
}

async function testOonMultiSymbols(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim, `# Test\n\n- □ '● ✔' test symbols\n- bullet item\n`);
  const lines = await testKey(nvim, 3, "o", "new line");
  const line = lines[3] || "";
  const ok = hasCheckbox(line) && line.includes("new line");
  return check("'o' on □●✔ line", ok, `line 4: "${line.trim()}"`);
}

async function testOonBullet(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim);
  const lines = await testKey(nvim, 4, "o", "new bullet");
  const line = lines[4] || "";
  const ok = line.trim() === "- new bullet";
  return check("'o' on bullet creates bullet", ok, `line 5: "${line.trim()}"`);
}

async function testOonNumbered(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim);
  const lines = await testKey(nvim, 5, "o", "second item");
  const line = lines[5] || "";
  const ok = line.trim() === "2. second item";
  return check("'o' on numbered continues", ok, `line 6: "${line.trim()}"`);
}

async function testOonBlockquote(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim);
  const lines = await testKey(nvim, 6, "o", "continued quote");
  const line = lines[6] || "";
  const ok = line.trim() === "> continued quote";
  return check("'o' on blockquote continues", ok, `line 7: "${line.trim()}"`);
}

async function testOonIndentedBlockquote(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim, `# Test\n\n- [ ] todo item\n    > indented blockquote\n`);
  const lines = await testKey(nvim, 4, "o", "next line");
  const line = lines[4] || "";
  const ok = line === "    > next line";
  return check("'o' on indented blockquote", ok, `"${line}"`);
}

// Test 'O' creates line above
async function testUpperOonTodo(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim);
  const lines = await testKey(nvim, 3, "O", "above todo");
  const line = lines[2] || "";
  const ok = hasCheckbox(line) && line.includes("above todo");
  return check("'O' on todo creates checkbox above", ok, `line 3: "${line.trim()}"`);
}

async function testUpperOonBlockquote(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim);
  const lines = await testKey(nvim, 6, "O", "above quote");
  const line = lines[5] || "";
  const ok = line.trim() === "> above quote";
  return check("'O' on blockquote creates above", ok, `line 6: "${line.trim()}"`);
}

async function testUpperOonIndentedBlockquote(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim, `# Test\n\n- [ ] todo item\n    > indented blockquote\n`);
  const lines = await testKey(nvim, 4, "O", "above indented");
  const line = lines[3] || "";
  const ok = line === "    > above indented";
  return check("'O' on indented blockquote", ok, `"${line}"`);
}

// Check if line has checked state (raw [x] or rendered ✔/●)
function isCheckedState(line: string): boolean {
  return line.includes("[x]") || line.includes("✔") || line.includes("●");
}

// Check if line has unchecked state (raw [ ] or rendered □)
function isUncheckedState(line: string): boolean {
  return line.includes("[ ]") || line.includes("□");
}

// Test <leader>tt toggle
async function testToggleRaw(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim);
  const lines = await testKey(nvim, 3, "<Space>tt");
  const line = lines[2] || "";
  return check("<leader>tt toggles checkbox", isCheckedState(line), `line 3: "${line.trim()}"`);
}

async function testToggleRendered(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim, `# Test\n\n- □ rendered unchecked\n`);
  const lines = await testKey(nvim, 3, "<Space>tt");
  const line = lines[2] || "";
  return check("<leader>tt on rendered", isCheckedState(line), `line 3: "${line.trim()}"`);
}

async function testToggleChecked(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim, `# Test\n\n- ✔ checked item\n`);
  const lines = await testKey(nvim, 3, "<Space>tt");
  const line = lines[2] || "";
  return check("<leader>tt on checked (✔)", isUncheckedState(line), `line 3: "${line.trim()}"`);
}

async function testToggleMultiSymbols(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim, `# Test\n\n- □ '● ✔' test symbols\n`);
  const lines = await testKey(nvim, 3, "<Space>tt");
  const line = lines[2] || "";
  // First □ should toggle to checked, rest unchanged
  const toggled = isCheckedState(line) && line.includes("'● ✔'");
  return check("<leader>tt on □●✔ line", toggled, `line 3: "${line.trim()}"`);
}

async function testToggleCheckedMultiSymbols(nvim: NeovimClient): Promise<boolean> {
  // Toggle on checked line with multiple symbols - should toggle first ✔ only
  await reloadFile(nvim, `# Test\n\n- ✔ '● ✔' test symbols\n`);
  const lines = await testKey(nvim, 3, "<Space>tt");
  const line = lines[2] || "";
  // First ✔ should become unchecked, rest should remain unchanged
  const toggled = isUncheckedState(line) && line.includes("'● ✔'");
  return check("<leader>tt on ✔●✔ line", toggled, `line 3: "${line.trim()}"`);
}

// Test <CR> continuation in insert mode
async function testCRonTodo(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim);
  await nvim.command("3");
  await nvim.input("A"); // Append at end
  await Bun.sleep(200);
  await nvim.input("<CR>");
  await Bun.sleep(300);
  await nvim.input("todo via enter");
  await nvim.input("<Esc>");
  await Bun.sleep(200);
  const lines = await getLines(nvim);
  const line = lines[3] || "";
  const ok = (line.includes("[ ]") || line.includes("□")) && line.includes("todo via enter");
  return check("<CR> on todo creates checkbox", ok, `line 4: "${line.trim()}"`);
}

async function testCRonRendered(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim, `# Test\n\n- □ rendered checkbox\n`);
  await nvim.command("3");
  await nvim.input("A");
  await Bun.sleep(200);
  await nvim.input("<CR>");
  await Bun.sleep(300);
  await nvim.input("new via enter");
  await nvim.input("<Esc>");
  await Bun.sleep(200);
  const lines = await getLines(nvim);
  const line = lines[3] || "";
  const ok = (line.includes("[ ]") || line.includes("□")) && line.includes("new via enter");
  return check("<CR> on rendered checkbox", ok, `line 4: "${line.trim()}"`);
}

// Test ]<Space> and [<Space>
async function testBracketSpaceBelow(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim);
  const lines = await testKey(nvim, 3, "]<Space>");
  const line = lines[3] || "";
  const ok = hasCheckbox(line) && !!line.trim().match(/^-\s+\[.\]$|^-\s+□$/);
  return check("]<Space> on todo creates checkbox", ok, `line 4: "${line.trim()}"`);
}

async function testBracketSpaceAbove(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim);
  const lines = await testKey(nvim, 3, "[<Space>");
  const line = lines[2] || "";
  const ok = hasCheckbox(line) && !!line.trim().match(/^-\s+\[.\]$|^-\s+□$/);
  return check("[<Space> on todo creates checkbox", ok, `line 3: "${line.trim()}"`);
}

// --- Main ---

async function main() {
  header("nvim markdown list continuation");

  let sectionNum = 0;
  const nextSection = (name: string) => section(++sectionNum, name);

  try {
    nextSection("Setup");
    const client = await withTimeout(setup(), 15000, "setup");
    console.log("nvim started with remote API\n");

    const tests: [string, () => Promise<boolean>][] = [
      ["Check mapping", () => testMapping(client)],
      // 'o' tests
      ["'o' on todo (raw)", () => testOonTodo(client)],
      ["'o' on todo (rendered)", () => testOonRendered(client)],
      ["'o' on checked (✔)", () => testOonChecked(client)],
      ["'o' on □●✔ line", () => testOonMultiSymbols(client)],
      ["'o' on bullet", () => testOonBullet(client)],
      ["'o' on numbered", () => testOonNumbered(client)],
      ["'o' on blockquote", () => testOonBlockquote(client)],
      ["'o' on indented blockquote", () => testOonIndentedBlockquote(client)],
      // 'O' tests
      ["'O' on todo", () => testUpperOonTodo(client)],
      ["'O' on blockquote", () => testUpperOonBlockquote(client)],
      ["'O' on indented blockquote", () => testUpperOonIndentedBlockquote(client)],
      // toggle tests
      ["<leader>tt toggle (raw)", () => testToggleRaw(client)],
      ["<leader>tt toggle (rendered)", () => testToggleRendered(client)],
      ["<leader>tt toggle (checked ✔)", () => testToggleChecked(client)],
      ["<leader>tt on □●✔ line", () => testToggleMultiSymbols(client)],
      ["<leader>tt on ✔●✔ line", () => testToggleCheckedMultiSymbols(client)],
      // <CR> tests
      ["<CR> continuation (raw)", () => testCRonTodo(client)],
      ["<CR> continuation (rendered)", () => testCRonRendered(client)],
      // bracket tests
      ["]<Space> on todo", () => testBracketSpaceBelow(client)],
      ["[<Space> on todo", () => testBracketSpaceAbove(client)],
    ];

    let passed = 0;
    for (const [name, testFn] of tests) {
      nextSection(name);
      if (await withTimeout(testFn(), 5000, name)) passed++;
    }

    nextSection("Summary");
    console.log(`\nPassed: ${passed}/${tests.length}`);

    if (passed < tests.length) {
      console.log(`
Troubleshooting:
  1. Restart nvim after config changes
  2. Run :Lazy to verify plugins loaded
  3. Run :verbose nmap o to check mapping
`);
    }

    process.exit(passed === tests.length ? 0 : 1);
  } catch (err) {
    console.error("Error:", err);
    process.exit(1);
  } finally {
    await cleanup();
  }
}

main();
