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

// --- Managed tmux session for TUI testing (yazi, etc.) ---
//
// Drive: `start({cmd, cwd, ...})` → `sendRaw|sendLiteral` → `waitFor(anchor)`.
// Never sleep on a fixed timer — poll capture-pane until the screen reaches
// the expected state. Pattern lifted from fzf's `test/lib/common.rb` (`Tmux#wait`).
//
// Pinning -x/-y/TERM/LANG keeps capture output reproducible across host
// terminals. escape-time=0 makes <Esc> dispatch immediately instead of after
// tmux's default 500ms grace.

export interface TmuxStartOpts {
  cmd: string;
  cwd: string;
  cols?: number;
  rows?: number;
  // Inserted as raw `KEY=value` pairs into the wrapper `sh -c`. Values are
  // *not* shell-escaped — callers can use `$VAR` to inherit, but must quote
  // any whitespace/specials themselves. (Wrapper exists because tmux's
  // `-e KEY=VAL` flag is shadowed by the user's `update-environment`.)
  env?: Record<string, string>;
}

export interface TmuxWaitOpts {
  timeout?: number;     // ms, default 5000
  poll?: number;        // ms, default 50
  scrollback?: boolean; // include off-screen lines, default false
}

export type TmuxMatcher = string | RegExp | ((screen: string) => boolean);

export class TmuxRunner {
  constructor(public readonly session: string) {}

  async start(opts: TmuxStartOpts): Promise<void> {
    await this.kill();
    const cols = opts.cols ?? 120;
    const rows = opts.rows ?? 40;
    const env = { TERM: "xterm-256color", LANG: "en_US.UTF-8", ...(opts.env ?? {}) };
    const exports = Object.entries(env).map(([k, v]) => `${k}=${v}`).join(" ");
    const wrapped = `${exports} exec ${opts.cmd}`;
    // Chain new-session + set-option in one tmux invocation.
    await $`tmux new-session -d -s ${this.session} -x ${cols} -y ${rows} -c ${opts.cwd} sh -c ${wrapped} \; set-option -t ${this.session} escape-time 0`.quiet();
  }

  async sendRaw(keys: string): Promise<void> {
    await $`tmux send-keys -t ${this.session} -- ${keys}`.quiet();
  }

  async sendLiteral(text: string): Promise<void> {
    await $`tmux send-keys -t ${this.session} -l -- ${text}`.quiet();
  }

  async capture(opts: { scrollback?: boolean } = {}): Promise<string> {
    const result = opts.scrollback
      ? await $`tmux capture-pane -t ${this.session} -p -S -`.quiet()
      : await $`tmux capture-pane -t ${this.session} -p`.quiet();
    return result.text();
  }

  // Poll capture until matcher passes; throw with last screen on timeout.
  async waitFor(matcher: TmuxMatcher, opts: TmuxWaitOpts = {}): Promise<string> {
    const test = matcherFn(matcher);
    let lastScreen = "";
    return pollUntil(
      async () => (lastScreen = await this.capture({ scrollback: opts.scrollback })),
      test,
      {
        timeout: opts.timeout ?? 5000,
        poll: opts.poll ?? 50,
        describe: () => `${describeMatcher(matcher)}\n--- last screen ---\n${lastScreen}`,
      },
    );
  }

  async kill(): Promise<void> {
    await $`tmux kill-session -t ${this.session}`.nothrow().quiet();
  }
}

function matcherFn(m: TmuxMatcher): (s: string) => boolean {
  if (typeof m === "string") return (s) => s.includes(m);
  if (m instanceof RegExp) return (s) => m.test(s);
  return m;
}

function describeMatcher(m: TmuxMatcher): string {
  if (typeof m === "string") return JSON.stringify(m);
  if (m instanceof RegExp) return m.toString();
  return "<predicate>";
}

// --- Generic poll-until-condition ---
//
// Used by TmuxRunner.waitFor and waitForFile. Calls `probe` every `poll` ms;
// returns the first probed value that satisfies `test`. Throws on timeout.

export interface PollOpts {
  timeout?: number;            // ms, default 5000
  poll?: number;               // ms, default 50
  describe?: string | (() => string); // used in timeout message
}

export async function pollUntil<T>(
  probe: () => Promise<T>,
  test: (v: T) => boolean,
  opts: PollOpts = {},
): Promise<T> {
  const timeout = opts.timeout ?? 5000;
  const poll = opts.poll ?? 50;
  const deadline = Date.now() + timeout;
  while (Date.now() < deadline) {
    const v = await probe();
    if (test(v)) return v;
    await Bun.sleep(poll);
  }
  const detail = typeof opts.describe === "function" ? opts.describe() : opts.describe ?? "";
  throw new Error(`pollUntil timed out after ${timeout}ms${detail ? `: ${detail}` : ""}`);
}

export async function waitForFile(path: string, opts: PollOpts = {}): Promise<void> {
  await pollUntil(() => Bun.file(path).exists(), (v) => v, { describe: `file ${path}`, ...opts });
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
