# Neovim Plugin Testing

E2E testing for neovim plugins using headless nvim and Bun's test framework.

## Running Tests

```bash
cd diagnostics
bun test nvim-markdown-lists.test.ts  # Markdown list continuation
bun test nvim-csharp-lsp.test.ts      # C# LSP (csharp_ls)
bun test                               # All tests
```

## Using NvimRunner

The `NvimRunner` class in `lib.ts` manages headless nvim instances with automatic cleanup.

```typescript
import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { NvimRunner, NeovimClient } from "./lib";

const nvim = new NvimRunner();
let client: NeovimClient;

beforeAll(async () => {
  await Bun.write("/tmp/test.md", "# Test\n");
  client = await nvim.start("/tmp/nvim.sock", "/tmp/test.md");
  await nvim.setFiletype("markdown");
}, 15000);

afterAll(async () => {
  await nvim.cleanup("/tmp/test.md");
});
```

## NvimRunner Methods

| Method | Description |
|--------|-------------|
| `start(socket, file, cwd?)` | Start headless nvim, returns client |
| `setFiletype(ft)` | Set filetype and trigger autocmds |
| `getLines()` | Get all buffer lines |
| `reloadContent(file, content)` | Write content and reload buffer |
| `waitForLsp(name, timeout?)` | Wait for LSP to attach |
| `getLspClients()` | Get active LSP client names |
| `kill()` | Kill nvim process |
| `cleanup(...paths)` | Kill and remove temp files |

## Fixtures

Test fixtures live in `diagnostics/fixtures/`. Use fixtures when tests need persistent files (e.g., file explorer tests) rather than temp files that get cleaned up.

## Testing Key Sequences

```typescript
// Go to line, press key, type text
await client.command("3");
await client.input("o");
await Bun.sleep(300);
await client.input("typed text");
await client.input("<Esc>");

// Check result
const lines = await nvim.getLines();
expect(lines[3]).toMatch(/^- typed text$/);
```

## LSP Test Assertions

```typescript
import {
  assertLspAttached,
  assertHoverWorks,
  assertMappingExists,
  assertCompletionAvailable,
  assertInlayHintsEnabled,
  assertDiagnosticsWork,
} from "./lib";

it("LSP attaches", async () => {
  await assertLspAttached(nvim, "csharp_ls");
});

it("hover works", async () => {
  await client.command("9");
  await assertHoverWorks(client);
});

it("gd mapped", async () => {
  await assertMappingExists(client, "gd", /lsp|definition/);
});
```
