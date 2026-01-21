import { $ } from "bun";
import { consola } from "consola";
import { spawn, ChildProcess } from "child_process";
import { attach, NeovimClient } from "neovim";

export { NeovimClient };

// --- SSH helpers ---

export const macmini = "macmini";
export const macminiHost = "macmini.studioboxcat.com";

export async function ssh(cmd: string): Promise<string> {
  const result = await $`ssh ${macmini} ${cmd}`.quiet().nothrow();
  return result.text();
}

export async function sshGrep(pattern: string, file: string): Promise<boolean> {
  const out = await ssh(`grep -q '${pattern}' ${file} 2>/dev/null && echo OK`);
  return out.includes("OK");
}

// --- Console output helpers ---

export function check(name: string, ok: boolean, note?: string): boolean {
  const msg = note ? `${name} — ${note}` : name;
  ok ? consola.success(msg) : consola.fail(msg);
  return ok;
}

export function header(title: string) {
  consola.box(title);
}

export function section(num: number, title: string) {
  console.log();
  consola.info(`[${num}] ${title}`);
  console.log();
}

// --- Managed headless nvim instance ---

export class NvimRunner {
  private process: ChildProcess | null = null;
  private socketPath: string = "";
  client: NeovimClient | null = null;

  constructor() {
    process.on("SIGINT", () => process.exit(1));
    process.on("SIGTERM", () => process.exit(1));
    process.on("exit", () => this.kill());
  }

  async start(socketPath: string, file: string, cwd?: string): Promise<NeovimClient> {
    this.socketPath = socketPath;

    // Kill any zombie nvim using this socket
    await $`pkill -9 -f "nvim.*${socketPath}"`.nothrow().quiet();
    await $`rm -f ${socketPath}`.nothrow();

    this.process = spawn("nvim", ["--headless", "--listen", socketPath, "-n", file], {
      stdio: ["pipe", "pipe", "pipe"],
      cwd,
    });
    this.process.stderr?.on("data", (d) => console.error("nvim:", d.toString().trim()));

    // Wait for socket
    for (let i = 0; i < 30; i++) {
      if (await Bun.file(socketPath).exists()) break;
      await Bun.sleep(100);
    }

    this.client = attach({ socket: socketPath });
    await Bun.sleep(300);
    return this.client;
  }

  async setFiletype(ft: string) {
    if (!this.client) throw new Error("nvim not started");
    await this.client.command(`set filetype=${ft}`);
    await this.client.command(`doautocmd FileType ${ft}`);
    await Bun.sleep(300);
  }

  async getLines(): Promise<string[]> {
    if (!this.client) return [];
    const buf = await this.client.buffer;
    return buf.getLines({ start: 0, end: -1, strictIndexing: false });
  }

  async reloadContent(file: string, content: string) {
    if (!this.client) return;
    await Bun.write(file, content);
    await this.client.command("e!");
    await Bun.sleep(300);
  }

  async waitForLsp(name: string, timeoutMs = 30000): Promise<boolean> {
    if (!this.client) return false;
    const start = Date.now();
    while (Date.now() - start < timeoutMs) {
      try {
        // Use vim.tbl_map to extract just the names (avoids mixed-key table serialization issues)
        const names = await this.client.call("luaeval", [
          "vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients())"
        ]) as string[];
        if (names?.includes(name)) return true;
      } catch {}
      await Bun.sleep(500);
    }
    return false;
  }

  async getLspClients(): Promise<string[]> {
    if (!this.client) return [];
    const names = await this.client.call("luaeval", [
      "vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients())"
    ]) as string[];
    return names ?? [];
  }

  kill() {
    if (this.client) {
      try { this.client.command("qa!"); } catch {}
      this.client = null;
    }
    if (this.process) {
      this.process.kill("SIGKILL"); // Force kill, SIGTERM often ignored
      this.process = null;
    }
  }

  async cleanup(...paths: string[]) {
    this.kill();
    for (const p of [this.socketPath, ...paths]) {
      if (p) await $`rm -rf ${p}`.nothrow();
    }
  }
}

// --- Common LSP test assertions ---

export async function assertLspAttached(nvim: NvimRunner, lspName: string): Promise<void> {
  const attached = await nvim.waitForLsp(lspName);
  if (!attached) {
    const clients = await nvim.getLspClients();
    throw new Error(`LSP '${lspName}' not attached. Active: ${clients.join(", ") || "none"}`);
  }
}

export async function assertHoverWorks(client: NeovimClient): Promise<void> {
  await client.call("luaeval", ["vim.lsp.buf.hover()"]);
  await Bun.sleep(1000);
  const wins = await client.call("luaeval", ["vim.api.nvim_list_wins()"]) as number[];
  if (wins.length <= 1) throw new Error("No hover window opened");
}

export async function assertMappingExists(client: NeovimClient, key: string, pattern: RegExp): Promise<void> {
  const output = await client.commandOutput(`verbose nmap ${key}`);
  if (!pattern.test(output)) throw new Error(`Mapping '${key}' not found or doesn't match pattern`);
}

export async function assertCompletionAvailable(client: NeovimClient): Promise<void> {
  const has = await client.call("luaeval", [
    "(function() for _, c in ipairs(vim.lsp.get_clients()) do if c.server_capabilities.completionProvider then return true end end return false end)()"
  ]) as boolean;
  if (!has) throw new Error("No LSP completion provider");
}

export async function assertInlayHintsEnabled(client: NeovimClient): Promise<void> {
  const enabled = await client.call("luaeval", ["vim.lsp.inlay_hint.is_enabled()"]) as boolean;
  if (!enabled) throw new Error("Inlay hints not enabled");
}

export async function assertDiagnosticsWork(client: NeovimClient, invalidCode: string): Promise<void> {
  await client.command("normal! Go");
  await client.input("i" + invalidCode);
  await client.input("<Esc>");
  await Bun.sleep(2000);

  const diagnostics = await client.call("luaeval", ["vim.diagnostic.get(0)"]) as any[];
  await client.command("u");

  if (!diagnostics?.length) throw new Error("No diagnostics reported for invalid code");
}

// --- Common test helpers ---

export async function typeKeys(client: NeovimClient, ...keys: string[]) {
  for (const k of keys) {
    await client.input(k);
    await Bun.sleep(150);
  }
}

export async function getLines(client: NeovimClient): Promise<string[]> {
  const buf = await client.buffer;
  return buf.getLines({ start: 0, end: -1, strictIndexing: false });
}

export async function getLine(client: NeovimClient, n: number): Promise<string> {
  const lines = await getLines(client);
  return lines[n] ?? "";
}

// --- Utility ---

export async function withTimeout<T>(promise: Promise<T>, ms: number, name: string): Promise<T> {
  return Promise.race([
    promise,
    new Promise<T>((_, reject) =>
      setTimeout(() => reject(new Error(`${name} timed out after ${ms}ms`)), ms)
    ),
  ]);
}

export async function fileExists(path: string): Promise<boolean> {
  return Bun.file(path).exists();
}

export async function commandExists(cmd: string): Promise<boolean> {
  const result = await $`which ${cmd}`.nothrow().quiet();
  return result.exitCode === 0;
}
