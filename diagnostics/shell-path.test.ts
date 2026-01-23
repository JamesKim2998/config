/**
 * Shell PATH and zsh config tests
 * Run: bun test shell-path.test.ts
 */

import { $ } from "bun";
import { describe, it, expect } from "bun:test";
import { macmini } from "./lib";

// Zsh special arrays - never use as variable names (e.g., `while read path`)
// These are tied to uppercase env vars: path↔PATH, fpath↔FPATH, etc.
const ZSH_SPECIAL_ARRAYS = ["path", "fpath", "cdpath", "manpath", "mailpath"];

type ShellMode = "login" | "interactive" | "login+interactive";

const shellFlags: Record<ShellMode, string> = {
  login: "-l",
  interactive: "-i",
  "login+interactive": "-il",
};

async function shellCommandExists(cmd: string, mode: ShellMode, remote = false): Promise<boolean> {
  const flags = shellFlags[mode];
  const shellCmd = `zsh ${flags} -c 'type ${cmd}'`;
  const result = remote
    ? await $`ssh ${macmini} ${shellCmd}`.nothrow().quiet()
    : await $`sh -c ${shellCmd}`.nothrow().quiet();
  return result.exitCode === 0;
}

// Commands that should be available in login shell (.zshenv)
const LOGIN_CMDS = ["nvim", "fzf", "rg", "fd", "bat", "eza", "zoxide", "yazi", "lazygit", "bun", "starship"];

// Commands that require interactive shell (.zshrc)
const INTERACTIVE_CMDS = ["z"];

describe("local: login shell", () => {
  for (const cmd of LOGIN_CMDS) {
    it(cmd, async () => {
      expect(await shellCommandExists(cmd, "login")).toBe(true);
    });
  }
});

describe("local: login+interactive shell", () => {
  for (const cmd of INTERACTIVE_CMDS) {
    it(cmd, async () => {
      expect(await shellCommandExists(cmd, "login+interactive")).toBe(true);
    });
  }
});

describe("remote: login shell", () => {
  for (const cmd of LOGIN_CMDS) {
    it(cmd, async () => {
      expect(await shellCommandExists(cmd, "login", true)).toBe(true);
    });
  }
});

describe("remote: login+interactive shell", () => {
  for (const cmd of INTERACTIVE_CMDS) {
    it(cmd, async () => {
      expect(await shellCommandExists(cmd, "login+interactive", true)).toBe(true);
    });
  }
});

describe("zsh special variable misuse", () => {
  it("no misuse of path/fpath/cdpath/manpath in shell scripts", async () => {
    const configDir = import.meta.dir.replace("/diagnostics", "");
    const pattern = `read (${ZSH_SPECIAL_ARRAYS.join("|")})\\b`;
    const result = await $`grep -rn -E ${pattern} ${configDir} --include="*.zsh" --include=".zsh*"`.nothrow().quiet();
    const violations = result.stdout.toString().trim();
    expect(violations).toBe("");
  });
});
