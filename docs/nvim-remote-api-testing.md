# Neovim Remote API Testing

E2E testing for neovim plugins using the remote API with headless nvim.

See `diagnostics/nvim-markdown-lists.ts` for example. Run with `cd diagnostics && bun run nvim`.

## Setup

```typescript
import { attach, NeovimClient } from "neovim";
import { spawn, ChildProcess } from "child_process";

const SOCKET_PATH = "/tmp/nvim-test.sock";

// Start nvim with socket
const nvimProcess = spawn("nvim", ["--headless", "--listen", SOCKET_PATH, "-n", testFile]);

// Wait for socket
for (let i = 0; i < 20; i++) {
  if (await Bun.file(SOCKET_PATH).exists()) break;
  await Bun.sleep(100);
}

// Connect
const nvim = await attach({ socket: SOCKET_PATH });

// Force load lazy plugins
await nvim.command("Lazy load plugin-name");
await nvim.command("set filetype=markdown");
await nvim.command("doautocmd FileType markdown");
```

## Testing Key Sequences

```typescript
// Go to line, press key, type text
await nvim.command("3");
await nvim.input("o");
await Bun.sleep(300);
await nvim.input("typed text");
await nvim.input("<Esc>");

// Read buffer content
const buf = await nvim.buffer;
const lines = await buf.getLines({ start: 0, end: -1, strictIndexing: false });
```

## Cleanup

```typescript
await nvim.command("qa!");
nvimProcess.kill();
await Bun.$`rm -f ${SOCKET_PATH}`.nothrow();
```

