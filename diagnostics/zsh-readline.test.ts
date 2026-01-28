/**
 * zsh readline keybindings in vi mode
 * Tests that Ctrl+A and Ctrl+E work despite vi mode being enabled
 * Run: bun test zsh-readline.test.ts
 */

import { $ } from "bun";
import { describe, it, expect } from "bun:test";

async function getBinding(key: string): Promise<string> {
  const result = await $`zsh -ic "bindkey '${key}'"`.quiet().nothrow();
  return result.text().trim();
}

describe("zsh readline keybindings (vi mode)", () => {
  it("Ctrl+A bound to beginning-of-line", async () => {
    const binding = await getBinding("^a");
    expect(binding).toContain("beginning-of-line");
  });

  it("Ctrl+E bound to end-of-line", async () => {
    const binding = await getBinding("^e");
    expect(binding).toContain("end-of-line");
  });
});
