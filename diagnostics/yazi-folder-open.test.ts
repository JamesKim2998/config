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

const TEST_DIR = "/tmp/yazi-folder-open-test";
const BIN_DIR = `${TEST_DIR}/bin`;
const EDIT_MARKER = `${TEST_DIR}/edit-called`;
const OPEN_MARKER = `${TEST_DIR}/open-called`;
const SESSION = "yazi-folder-open-test";

async function startYazi() {
  await $`tmux kill-session -t ${SESSION}`.nothrow().quiet();
  await $`rm -f ${EDIT_MARKER} ${OPEN_MARKER}`.quiet();
  // tmux's `-e` is overridden by the user's `update-environment`, so wrap in sh
  // and set env there. PATH shim must come first so `open` resolves to our stub.
  const cmd = `EDITOR='${BIN_DIR}/fake-editor' PATH='${BIN_DIR}':"$PATH" exec yazi`;
  await $`tmux new-session -d -s ${SESSION} -c ${TEST_DIR} sh -c ${cmd}`.quiet();
  await Bun.sleep(1500);
}

async function send(keys: string, delay = 300) {
  await $`tmux send-keys -t ${SESSION} -- ${keys}`.quiet();
  await Bun.sleep(delay);
}

async function killYazi() {
  await $`tmux kill-session -t ${SESSION}`.nothrow().quiet();
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
  await killYazi();
  await $`rm -rf ${TEST_DIR}`.nothrow();
});

beforeEach(async () => {
  await killYazi();
});

async function pressOOn(name: string) {
  await startYazi();
  // yazi sorts dirs first, then files alphabetically. Use 'gg' then '/' filter.
  await send("gg", 200);
  await send("/", 200);
  await $`tmux send-keys -t ${SESSION} -l -- ${name}`.quiet();
  await Bun.sleep(400);
  await send("Enter", 400);
  await send("o", 1000);
}

describe("yazi 'o' on folders", () => {
  it("should call macOS `open` (not $EDITOR) on a regular folder", async () => {
    await pressOOn("subdir");
    expect(await Bun.file(OPEN_MARKER).exists()).toBe(true);
    expect(await Bun.file(EDIT_MARKER).exists()).toBe(false);
  }, 15000);

  it("should call macOS `open` (not $EDITOR) on a .app bundle", async () => {
    await pressOOn("MyApp.app");
    expect(await Bun.file(OPEN_MARKER).exists()).toBe(true);
    expect(await Bun.file(EDIT_MARKER).exists()).toBe(false);
  }, 15000);

  it("should still call $EDITOR on a regular text file (sanity)", async () => {
    await pressOOn("regular.txt");
    expect(await Bun.file(EDIT_MARKER).exists()).toBe(true);
    expect(await Bun.file(OPEN_MARKER).exists()).toBe(false);
  }, 15000);
});
