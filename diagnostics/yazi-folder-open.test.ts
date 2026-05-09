/**
 * yazi 'o' on directories should not invoke $EDITOR
 *
 * Default preset has a directory rule with `use = [ "edit", "open", "reveal" ]`,
 * so pressing 'o' on a folder runs `$EDITOR <folder>`. We override it so the
 * macOS `open` command runs first (covers .app bundles too).
 *
 * Test strategy: shadow $EDITOR with a marker script, and shadow the `open`
 * binary via PATH with another marker script. Press 'o' on each target; the
 * marker that appears tells us which opener yazi picked.
 *
 * Run: bun test yazi-folder-open.test.ts
 */

import { describe, it, expect, beforeAll, afterAll, beforeEach } from "bun:test";
import { $ } from "bun";
import { TmuxRunner, waitForFile } from "./lib";

const TEST_DIR = "/tmp/yazi-folder-open-test";
const BIN_DIR = `${TEST_DIR}/bin`;
const EDIT_MARKER = `${TEST_DIR}/edit-called`;
const OPEN_MARKER = `${TEST_DIR}/open-called`;
const tmux = new TmuxRunner("yazi-folder-open-test");

async function startYazi() {
  await $`rm -f ${EDIT_MARKER} ${OPEN_MARKER}`.quiet();
  await tmux.start({
    cmd: "yazi",
    cwd: TEST_DIR,
    env: {
      EDITOR: `${BIN_DIR}/fake-editor`,
      PATH: `${BIN_DIR}:$PATH`, // $PATH expands inside the wrapper sh
    },
  });
  await tmux.waitFor("subdir"); // directory row visible ⇒ UI ready
}

beforeAll(async () => {
  await $`rm -rf ${TEST_DIR}`.quiet();
  await $`mkdir -p ${BIN_DIR} ${TEST_DIR}/subdir ${TEST_DIR}/MyApp.app`.quiet();
  await Bun.write(`${TEST_DIR}/regular.txt`, "hello\n");

  // Marker scripts. Both write a marker and exit immediately so yazi resumes.
  await Bun.write(
    `${BIN_DIR}/fake-editor`,
    `#!/bin/sh\necho "$@" > ${EDIT_MARKER}\n`,
  );
  await Bun.write(
    `${BIN_DIR}/open`,
    `#!/bin/sh\necho "$@" > ${OPEN_MARKER}\n`,
  );
  await $`chmod +x ${BIN_DIR}/fake-editor ${BIN_DIR}/open`.quiet();
}, 10000);

afterAll(async () => {
  await tmux.kill();
  await $`rm -rf ${TEST_DIR}`.nothrow();
});

beforeEach(async () => {
  await tmux.kill();
});

// Soft-filter prompt has no visible state until chars are typed; small wait
// so the next chars don't trigger manager-mode bindings.
const PROMPT_OPEN = 100;

async function pressOOn(name: string) {
  await startYazi();
  await tmux.sendRaw("gg");
  await tmux.sendRaw("/");
  await Bun.sleep(PROMPT_OPEN);
  await tmux.sendLiteral(name);
  await tmux.waitFor(`󰈲 ${name}`);  // chip with our query ⇒ filter prompt accepted input
  await tmux.sendRaw("Enter");
  await tmux.waitFor(`${TEST_DIR}/${name}`); // status path ⇒ cursor on target
  await tmux.sendRaw("o");
}

describe("yazi 'o' on folders", () => {
  it("should call macOS `open` (not $EDITOR) on a regular folder", async () => {
    await pressOOn("subdir");
    await waitForFile(OPEN_MARKER);
    expect(await Bun.file(EDIT_MARKER).exists()).toBe(false);
  }, 15000);

  it("should call macOS `open` (not $EDITOR) on a .app bundle", async () => {
    await pressOOn("MyApp.app");
    await waitForFile(OPEN_MARKER);
    expect(await Bun.file(EDIT_MARKER).exists()).toBe(false);
  }, 15000);

  it("should still call $EDITOR on a regular text file (sanity)", async () => {
    await pressOOn("regular.txt");
    await waitForFile(EDIT_MARKER);
    expect(await Bun.file(OPEN_MARKER).exists()).toBe(false);
  }, 15000);
});
