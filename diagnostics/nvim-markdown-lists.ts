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

// Note: o/O only handles checkboxes and blockquotes, not regular bullets
// For regular bullet continuation, use <CR> in insert mode
async function testOonBullet(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim);
  const lines = await testKey(nvim, 4, "o", "new bullet");
  const line = lines[4] || "";
  // Just inserts plain line (bullets.vim disabled for o/O)
  const ok = line.trim() === "new bullet";
  return check("'o' on bullet creates line", ok, `line 5: "${line.trim()}"`);
}

async function testOonNumbered(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim);
  const lines = await testKey(nvim, 5, "o", "second item");
  const line = lines[5] || "";
  // Just inserts plain line (bullets.vim disabled for o/O)
  const ok = line.trim() === "second item";
  return check("'o' on numbered creates line", ok, `line 6: "${line.trim()}"`);
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
  // Force checkmate to process the buffer
  try {
    await nvim.call("luaeval", ["require('checkmate')._start()"]);
    await nvim.call("luaeval", ["require('checkmate.api').process_buffer(0, 'full', 'test')"]);
  } catch {}
  await Bun.sleep(300);
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

// Test gitsigns modified status on checkmate-rendered lines
async function testGitsignsModified(nvim: NeovimClient): Promise<boolean> {
  // Create file, save it, then check if gitsigns shows modified
  const content = `# Test\n\n- [ ] todo item\n`;
  await Bun.write(TEST_FILE, content);
  await nvim.command("e!");
  await Bun.sleep(300);

  // Get buffer content
  const lines = await getLines(nvim);
  const line = lines[2] || "";

  // Check if buffer reports as modified
  const modified = await nvim.eval("&modified");

  // Get the actual raw text vs visual
  const rawLine = await nvim.call("getline", [3]) as string;

  // Check if checkmate replaced the content
  const wasReplaced = rawLine.includes("□") && !rawLine.includes("[ ]");

  const note = `raw="${rawLine}", modified=${modified}, replaced=${wasReplaced}`;

  // The bug: if checkmate replaces [ ] with □ in the buffer, it makes &modified true
  // This is wrong - rendering should use concealment/extmarks, not buffer modification
  const ok = !wasReplaced || modified === 0;
  return check("Checkmate render preserves buffer", ok, note);
}

// Test that checkbox text is not truncated after rendering
async function testTextNotTruncated(nvim: NeovimClient): Promise<boolean> {
  // Specifically test the case where "google" was being truncated to "gle"
  await reloadFile(nvim, `# Test\n\n- [ ] google play pass email reply\n`);

  // Force checkmate processing
  try {
    await nvim.call("luaeval", ["require('checkmate')._start()"]);
    await nvim.call("luaeval", ["require('checkmate.api').process_buffer(0, 'full', 'test')"]);
  } catch {}
  await Bun.sleep(500);

  // Get the actual buffer content (not visual)
  const rawLine = await nvim.call("getline", [3]) as string;

  // Buffer should still have the full text
  const hasFullText = rawLine.includes("google play pass email reply");
  const hasCheckbox = rawLine.includes("[ ]");

  // Check if any text appears truncated
  const isTruncated = rawLine.includes("gle play") && !rawLine.includes("google");

  const note = `raw="${rawLine}", hasFullText=${hasFullText}, isTruncated=${isTruncated}`;

  // Success: buffer has full text and checkbox, no truncation
  const ok = hasFullText && hasCheckbox && !isTruncated;
  return check("Checkbox text not truncated", ok, note);
}

// Test concealment extmarks are positioned correctly
async function testConcealmentPosition(nvim: NeovimClient): Promise<boolean> {
  await reloadFile(nvim, `# Test\n\n- [ ] google play pass email reply\n`);

  // Force checkmate processing
  try {
    await nvim.call("luaeval", ["require('checkmate')._start()"]);
    await nvim.call("luaeval", ["require('checkmate.api').process_buffer(0, 'full', 'test')"]);
  } catch {}
  await Bun.sleep(500);

  // Get concealment extmarks
  const extmarks = await nvim.call("luaeval", [
    "vim.api.nvim_buf_get_extmarks(0, require('checkmate.config').ns_conceal, 0, -1, {details=true})"
  ]) as any[];

  if (!extmarks || extmarks.length === 0) {
    return check("Concealment extmarks exist", false, "No concealment extmarks found");
  }

  // Check the first extmark (should be on line 3, at position of '[')
  const ext = extmarks[0];
  const row = ext[1];
  const col = ext[2];
  const details = ext[3];
  const endCol = details?.end_col;
  const concealChar = details?.conceal;

  // Line is "- [ ] google..." - checkbox starts at col 2 (0-indexed)
  // [ ] is 3 chars, so end_col should be 5
  const expectedCol = 2;
  const expectedEndCol = 5;

  const posCorrect = col === expectedCol && endCol === expectedEndCol;
  const note = `row=${row}, col=${col}, end_col=${endCol}, conceal="${concealChar}", expected col=${expectedCol}-${expectedEndCol}`;

  return check("Concealment position correct", posCorrect, note);
}

// Test with user's actual todo.md file
async function testUserTodoFile(nvim: NeovimClient): Promise<boolean> {
  const todoFile = "/Users/jameskim/Develop/todo/todo.md";

  // Check if file exists
  if (!await Bun.file(todoFile).exists()) {
    return check("User todo.md exists", false, "File not found");
  }

  // Open the file
  await nvim.command(`e ${todoFile}`);
  await Bun.sleep(300);

  // Force checkmate processing
  try {
    await nvim.call("luaeval", ["require('checkmate')._start()"]);
    await nvim.call("luaeval", ["require('checkmate.api').process_buffer(0, 'full', 'test')"]);
  } catch {}
  await Bun.sleep(500);

  // Find the "google play" line (should be around line 13)
  const lines = await getLines(nvim);
  const googleLineIdx = lines.findIndex(l => l.includes("google") || l.includes("gle"));

  if (googleLineIdx === -1) {
    return check("Find google line", false, "Line with 'google' not found");
  }

  const googleLine = lines[googleLineIdx];
  const hasFullText = googleLine.includes("google play pass email reply");
  const isTruncated = googleLine.includes("gle play") && !googleLine.includes("google");

  // Get concealment extmarks for this line
  const extmarks = await nvim.call("luaeval", [
    `vim.api.nvim_buf_get_extmarks(0, require('checkmate.config').ns_conceal, {${googleLineIdx}, 0}, {${googleLineIdx}, -1}, {details=true})`
  ]) as any[];

  let extmarkInfo = "no extmarks";
  if (extmarks && extmarks.length > 0) {
    const ext = extmarks[0];
    extmarkInfo = `col=${ext[2]}, end_col=${ext[3]?.end_col}`;
  }

  const note = `line ${googleLineIdx + 1}: "${googleLine.substring(0, 50)}...", extmarks: ${extmarkInfo}`;
  const ok = hasFullText && !isTruncated;
  return check("User todo.md not truncated", ok, note);
}

// Test gitsigns with actual git repo - verifies checkmate conversion behavior
async function testGitsignsInRepo(nvim: NeovimClient): Promise<boolean> {
  const testDir = "/tmp/nvim-gitsigns-test";
  const testFile = `${testDir}/test.md`;
  const content = `# Test\n\n- [ ] run the nonogram translation dry -> real\n`;

  // Setup git repo with [ ] checkbox
  await Bun.$`rm -rf ${testDir}`.nothrow();
  await Bun.$`mkdir -p ${testDir}`.nothrow();
  await Bun.write(testFile, content);
  await Bun.$`cd ${testDir} && git init && git add . && git commit -m "init"`.quiet();

  // Open file in nvim
  await nvim.command(`e ${testFile}`);
  await Bun.sleep(200);

  // Force checkmate processing
  try {
    await nvim.command("Lazy load checkmate.nvim");
    await nvim.command("set filetype=markdown");
    await nvim.command("doautocmd FileType markdown");
    // Force checkmate to start and convert
    await nvim.call("luaeval", ["require('checkmate')._start()"]);
    await nvim.call("luaeval", ["require('checkmate.api').process_buffer(0, 'full', 'test')"]);
  } catch (e) {
    console.log("  checkmate init error:", String(e).substring(0, 100));
  }
  await Bun.sleep(500); // Wait for checkmate debounce

  // Get buffer content immediately
  const rawLineAfterLoad = await nvim.call("getline", [3]) as string;

  // Wait more and check again
  await Bun.sleep(500);
  const rawLineAfterDelay = await nvim.call("getline", [3]) as string;

  // Check &modified
  const bufModified = await nvim.eval("&modified");

  // Force gitsigns attach
  try {
    await nvim.command("Gitsigns attach");
  } catch {}
  await Bun.sleep(300);

  // Get gitsigns hunks
  let gitsignsHunks = "";
  try {
    const hunks = await nvim.call("luaeval", ["require('gitsigns').get_hunks()"]);
    gitsignsHunks = JSON.stringify(hunks);
  } catch (e) {
    gitsignsHunks = `error: ${e}`;
  }

  // Cleanup
  await Bun.$`rm -rf ${testDir}`.nothrow();

  // With concealment fix: buffer should still have [ ] (not converted to □)
  const bufferHasMarkdown = rawLineAfterDelay.includes("[ ]");
  const hasHunks = gitsignsHunks !== "[]" && gitsignsHunks !== "null" && !gitsignsHunks.includes("error");

  const note = `bufContent="${bufferHasMarkdown ? "[ ]" : "□"}", modified=${bufModified}, gitsignsHunks=${hasHunks}`;

  // After concealment fix:
  // - Buffer should contain [ ] (markdown, not unicode)
  // - Gitsigns should show NO hunks (buffer matches git)
  const fixWorking = bufferHasMarkdown && !hasHunks;
  return check("Concealment fix: buffer=markdown, gitsigns=clean", fixWorking, note);
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
      // gitsigns/modified status
      ["Checkmate buffer preservation", () => testGitsignsModified(client)],
      ["Checkbox text not truncated", () => testTextNotTruncated(client)],
      ["Concealment position correct", () => testConcealmentPosition(client)],
      ["User todo.md not truncated", () => testUserTodoFile(client)],
      ["Gitsigns in git repo", () => testGitsignsInRepo(client)],
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
