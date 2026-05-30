/**
 * Kitty config-reload regression test
 * Run: bun test kitty-reload.test.ts
 *
 * Guards the kitty 0.47.0 regression where the `load_config_file` action
 * (reload-config, default cmd+ctrl+, on macOS) crashed with
 *   TypeError: argument 1 must be str or None, not tuple
 * via apply_theme -> patch_colors -> set_background_image (a tuple landing in
 * the `path` arg). Triggered on every reload, even with NO background_image
 * configured. Fixed in kitty 0.47.1.
 *
 * The test spins up a throwaway instance from the INSTALLED kitty binary (not
 * the one this session runs in) so it catches the bug regardless of what's
 * already running, and re-catches it if a future kitty version regresses.
 */

import { describe, it, expect } from "bun:test";
import { $ } from "bun";

const KITTY = "/Applications/kitty.app/Contents/MacOS/kitty";

const haveKitty = process.platform === "darwin" && (await Bun.file(KITTY).exists());

describe.if(haveKitty)("kitty config reload", () => {
  it("load_config_file action succeeds on the installed kitty (no tuple crash)", async () => {
    const sock = `/tmp/kitty-reload-test-${process.pid}`;
    await $`rm -f ${sock}`.nothrow().quiet();

    // Fresh process (own socket, minimized so it doesn't steal focus). No
    // --config: loads ~/.config/kitty — the symlinked repo config the user
    // actually runs, which is what exercises the apply_theme crash path.
    const proc = Bun.spawn(
      [
        KITTY,
        "--listen-on", `unix:${sock}`,
        "-o", "allow_remote_control=yes",
        "-o", "macos_quit_when_last_window_closed=yes",
        "--start-as=minimized",
        "--title", "kitty-reload-test",
        "zsh", "-c", "sleep 30",
      ],
      { stdout: "pipe", stderr: "pipe" },
    );

    try {
      // Wait for the control socket to appear.
      let up = false;
      for (let i = 0; i < 120; i++) {
        if ((await $`test -S ${sock}`.nothrow().quiet()).exitCode === 0) { up = true; break; }
        await Bun.sleep(50);
      }
      expect(up).toBe(true);
      await Bun.sleep(300); // let config finish loading

      const res = await $`kitty @ --to=unix:${sock} action load_config_file`.nothrow().quiet();
      const err = res.stderr.toString() + res.stdout.toString();
      // The regression surfaced as a non-zero exit + this exact message.
      expect(err).not.toContain("must be str or None");
      expect(res.exitCode).toBe(0);
    } finally {
      proc.kill();
      await $`rm -f ${sock}`.nothrow().quiet();
    }
  }, 20000);
});
