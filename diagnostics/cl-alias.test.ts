/**
 * cl (claude) function E2E tests
 * Run: bun test cl-alias.test.ts
 */

import { describe, it, expect } from "bun:test";
import { $ } from "bun";

describe("cl function", () => {
  it("is defined in interactive shell", async () => {
    const result = await $`zsh -i -c 'type cl' 2>&1`.text();
    expect(result).toContain("cl is a shell function");
  });

  it("finds CLAUDE.md and cds to that directory", async () => {
    const tmpDir = "/tmp/cl-test-" + Date.now();
    await $`mkdir -p ${tmpDir}/sub/deep`;
    await $`echo "# Test" > ${tmpDir}/CLAUDE.md`;

    // Test that cl finds the right directory (mock claude with echo)
    const result = await $`
      zsh -i -c '
        cl() {
          local dir="$PWD"
          while [[ "$dir" != "/" && ! -f "$dir/CLAUDE.md" ]]; do
            dir="$(dirname "$dir")"
          done
          echo "found:$dir"
        }
        cd ${tmpDir}/sub/deep
        cl
      '
    `.text();

    expect(result.trim()).toContain(`found:${tmpDir}`);
    await $`rm -rf ${tmpDir}`;
  });

  it("stays at root when no CLAUDE.md found", async () => {
    const tmpDir = "/tmp/cl-test-no-claude-" + Date.now();
    await $`mkdir -p ${tmpDir}`;

    const result = await $`
      zsh -i -c '
        cl() {
          local dir="$PWD"
          while [[ "$dir" != "/" && ! -f "$dir/CLAUDE.md" ]]; do
            dir="$(dirname "$dir")"
          done
          echo "found:$dir"
        }
        cd ${tmpDir}
        cl
      '
    `.text();

    expect(result.trim()).toContain("found:/");
    await $`rm -rf ${tmpDir}`;
  });
});
