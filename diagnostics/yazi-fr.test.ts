/**
 * yazi fr.yazi plugin tests
 * Tests for rg search via 'S' keybinding
 *
 * Issues tested:
 * 1. Case sensitivity: rg search should be case-insensitive
 * 2. Reveal navigation: selecting a result should navigate yazi to that file
 *
 * Run: bun test yazi-fr.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { $ } from "bun";

const TMUX_SESSION = "yazi-fr-test";
const TEST_DIR = "/tmp/yazi-fr-test";
const YAZI_STARTUP_DELAY = 1500;
const FZF_OPEN_DELAY = 1000;
const SEARCH_DELAY = 800;
const REVEAL_DELAY = 1000;

async function tmuxSendRaw(keys: string, delay = 100) {
  await $`tmux send-keys -t ${TMUX_SESSION} -- ${keys}`.quiet();
  await Bun.sleep(delay);
}

async function tmuxSendLiteral(keys: string, delay = 100) {
  await $`tmux send-keys -t ${TMUX_SESSION} -l -- ${keys}`.quiet();
  await Bun.sleep(delay);
}

async function tmuxCapture(): Promise<string> {
  const result = await $`tmux capture-pane -t ${TMUX_SESSION} -p`.quiet();
  return result.text();
}

async function setupTestFiles() {
  await $`rm -rf ${TEST_DIR}`.nothrow();
  await $`mkdir -p ${TEST_DIR}/subdir`.quiet();

  // Create test files with various case patterns
  await Bun.write(`${TEST_DIR}/lowercase.txt`, "this file has hello world in lowercase\n");
  await Bun.write(`${TEST_DIR}/uppercase.txt`, "THIS FILE HAS HELLO WORLD IN UPPERCASE\n");
  await Bun.write(`${TEST_DIR}/mixedcase.txt`, "This File Has Hello World in MixedCase\n");
  await Bun.write(`${TEST_DIR}/subdir/nested.txt`, "nested file with hello world content\n");
}

async function startYaziSession() {
  await $`tmux kill-session -t ${TMUX_SESSION}`.nothrow().quiet();
  await $`tmux new-session -d -s ${TMUX_SESSION} -c ${TEST_DIR} yazi`.quiet();
  await Bun.sleep(YAZI_STARTUP_DELAY);
}

async function killSession() {
  await $`tmux kill-session -t ${TMUX_SESSION}`.nothrow().quiet();
}

beforeAll(async () => {
  await setupTestFiles();
}, 10000);

afterAll(async () => {
  await killSession();
  await $`rm -rf ${TEST_DIR}`.nothrow();
});

describe("yazi fr.yazi case sensitivity", () => {
  it("should find all case variants when searching lowercase 'hello'", async () => {
    await startYaziSession();

    // Trigger rg search with Shift+S
    await tmuxSendRaw("S", FZF_OPEN_DELAY);

    // Type lowercase search pattern
    await tmuxSendLiteral("hello", SEARCH_DELAY);

    // Capture fzf output
    const output = await tmuxCapture();

    // Should show 4/4 matches (all files contain hello in various cases)
    expect(output).toContain("4/4");

    await killSession();
  }, 15000);

  it("should find all case variants when searching uppercase 'HELLO'", async () => {
    await startYaziSession();

    // Trigger rg search with Shift+S
    await tmuxSendRaw("S", FZF_OPEN_DELAY);

    // Type uppercase search pattern (with -i flag, should still find all)
    await tmuxSendLiteral("HELLO", SEARCH_DELAY);

    const output = await tmuxCapture();

    // With -i flag (case insensitive), all 4 files should be found
    expect(output).toContain("4/4");

    await killSession();
  }, 15000);
});

describe("yazi fr.yazi reveal navigation", () => {
  it("should navigate to selected file in current directory", async () => {
    await startYaziSession();

    // Trigger rg search with Shift+S
    await tmuxSendRaw("S", FZF_OPEN_DELAY);

    // Search for 'lowercase' (unique to lowercase.txt)
    await tmuxSendLiteral("lowercase", SEARCH_DELAY);

    // Press Enter to select
    await tmuxSendRaw("Enter", REVEAL_DELAY);

    // Capture yazi state
    const output = await tmuxCapture();

    // Status bar should show the full path to lowercase.txt
    expect(output).toContain(`${TEST_DIR}/lowercase.txt`);

    await killSession();
  }, 15000);

  it("should navigate to selected file in subdirectory", async () => {
    await startYaziSession();

    // Trigger rg search with Shift+S
    await tmuxSendRaw("S", FZF_OPEN_DELAY);

    // Search for 'nested' (unique to nested.txt in subdir)
    await tmuxSendLiteral("nested", SEARCH_DELAY);

    // Press Enter to select
    await tmuxSendRaw("Enter", REVEAL_DELAY);

    // Capture yazi state
    const output = await tmuxCapture();

    // Status bar should show the full path including subdir
    expect(output).toContain(`${TEST_DIR}/subdir/nested.txt`);

    await killSession();
  }, 15000);
});
