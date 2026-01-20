import { $ } from "bun";
import { consola } from "consola";
import { header, section } from "./lib";

const STARTUP_LOG = "/tmp/nvim-startup.log";
const RUNS = 5;

interface TimingEntry { time: number; selfTime: number; name: string }

const fmtMs = (ms: number) => ms.toFixed(1).padStart(6) + " ms";
const printRow = (label: string, ms: number, labelWidth = 25) =>
  console.log(`  ${label.slice(0, labelWidth).padEnd(labelWidth)} ${fmtMs(ms)}`);

async function benchmark(): Promise<number[]> {
  const times: number[] = [];
  for (let i = 0; i < RUNS; i++) {
    await $`nvim --headless --startuptime ${STARTUP_LOG} +q`.quiet();
    const match = (await Bun.file(STARTUP_LOG).text()).match(/(\d+\.\d+)\s+\d+\.\d+:\s+--- NVIM STARTED ---/);
    if (match) times.push(parseFloat(match[1]));
  }
  return times;
}

function parseLog(log: string): TimingEntry[] {
  return log.split("\n").flatMap((line) => {
    const m3 = line.match(/^\s*(\d+\.\d+)\s+\d+\.\d+\s+(\d+\.\d+):\s+(.+)$/);
    if (m3) return [{ time: parseFloat(m3[1]), selfTime: parseFloat(m3[2]), name: m3[3].trim() }];
    const m2 = line.match(/^\s*(\d+\.\d+)\s+(\d+\.\d+):\s+(.+)$/);
    if (m2) return [{ time: parseFloat(m2[1]), selfTime: parseFloat(m2[2]), name: m2[3].trim() }];
    return [];
  });
}

function getPluginTimings(entries: TimingEntry[]): Map<string, number> {
  const plugins = new Map<string, number>();
  const skip = new Set(["vim", "nvim", "ffi", "config"]);
  const patterns = [
    /sourcing .*\/\.local\/share\/nvim\/lazy\/([^/]+)\//,
    /sourcing .*\/pack\/[^/]+\/(?:start|opt)\/([^/]+)\//,
  ];

  for (const e of entries) {
    for (const pat of patterns) {
      const m = e.name.match(pat);
      if (m) { plugins.set(m[1], (plugins.get(m[1]) || 0) + e.selfTime); break; }
    }
    const req = e.name.match(/require\('([^']+)'\)/);
    if (req) {
      const mod = req[1].split(".")[0];
      if (!skip.has(mod)) plugins.set(mod, (plugins.get(mod) || 0) + e.selfTime);
    }
  }
  return plugins;
}

function getPhases(entries: TimingEntry[]): Map<string, number> {
  const markers = [
    [/--- NVIM STARTING ---/, "start"], [/init lua interpreter/, "lua"], [/init default mappings/, "defaults"],
    [/require\('lazy'\)$/, "lazy"], [/sourcing .*\.config\/nvim\/init\.lua/, "init.lua"],
    [/inits 3/, "syntax"], [/reading ShaDa/, "shada"], [/--- NVIM STARTED ---/, "ready"],
  ] as const;

  const times = entries.flatMap((e) => {
    for (const [pat, name] of markers) if (pat.test(e.name)) return [{ name, time: e.time }];
    return [];
  });

  const phases = new Map<string, number>();
  for (let i = 1; i < times.length; i++) {
    phases.set(`${times[i - 1].name} → ${times[i].name}`, times[i].time - times[i - 1].time);
  }
  return phases;
}

// Main
header("Neovim Startup Analysis");
let secNum = 0;
const sec = (t: string) => section(++secNum, t);

// Benchmark
sec("Startup Time Benchmark");
console.log(`  Running ${RUNS} iterations...`);
const times = await benchmark();
if (!times.length) { consola.error("Failed to get startup times"); process.exit(1); }

const avg = times.reduce((a, b) => a + b, 0) / times.length;
console.log(`\n  Average: ${fmtMs(avg)}\n  Min:     ${fmtMs(Math.min(...times))}\n  Max:     ${fmtMs(Math.max(...times))}`);

// Parse log
await $`nvim --headless --startuptime ${STARTUP_LOG} +q`.quiet();
const entries = parseLog(await Bun.file(STARTUP_LOG).text());

// Phases
sec("Startup Phases");
for (const [name, time] of getPhases(entries)) if (time > 0.1) printRow(name, time, 20);

// Time breakdown
sec("Time Breakdown");
const breakdown = { "require() calls": 0, "sourcing files": 0, "other (init)": 0 };
for (const e of entries) {
  if (e.name.includes("require(")) breakdown["require() calls"] += e.selfTime;
  else if (e.name.includes("sourcing")) breakdown["sourcing files"] += e.selfTime;
  else breakdown["other (init)"] += e.selfTime;
}
for (const [k, v] of Object.entries(breakdown)) printRow(k, v, 20);

// Plugins
sec("Top Plugins by Load Time");
const plugins = [...getPluginTimings(entries).entries()].filter(([, t]) => t > 0.5).sort((a, b) => b[1] - a[1]);
if (!plugins.length) console.log("  No significant plugin load times detected");
else for (const [name, time] of plugins.slice(0, 15)) printRow(name, time);

// Sourced files
sec("Slowest Sourced Files");
const files = new Map<string, number>();
for (const e of entries) {
  if (e.name.startsWith("sourcing") && !e.name.includes("nvim_exec2") && e.name.includes("/")) {
    const p = e.name.replace("sourcing ", "");
    files.set(p, (files.get(p) || 0) + e.selfTime);
  }
}
const srcFiles = [...files.entries()].filter(([, t]) => t > 0.3).sort((a, b) => b[1] - a[1]).slice(0, 10);
for (const [p, t] of srcFiles) printRow(p.split("/").slice(-2).join("/"), t, 35);

// Lazy.nvim stats
sec("Lazy.nvim Stats");
try {
  const out = await $`nvim --headless -c "lua print(vim.inspect(require('lazy').stats()))" +q 2>&1`.text();
  const loaded = out.match(/loaded\s*=\s*(\d+)/)?.[1], count = out.match(/count\s*=\s*(\d+)/)?.[1];
  if (loaded && count) {
    console.log(`  Loaded at startup: ${loaded}/${count} plugins\n  Lazy-loaded:       ${+count - +loaded} plugins`);
  }
} catch { console.log("  Lazy.nvim not detected"); }

// Lazy profile (top 10 slowest)
sec("Lazy.nvim Profile (top 10)");
try {
  const lua = `
    local plugins = {}
    for _, p in ipairs(require('lazy').plugins()) do
      if p._.loaded and p._.loaded.time then
        table.insert(plugins, {name = p.name, time = p._.loaded.time})
      end
    end
    table.sort(plugins, function(a, b) return a.time > b.time end)
    for i = 1, math.min(10, #plugins) do
      print(string.format('%6.2f ms  %s', plugins[i].time / 1000000, plugins[i].name))
    end
  `.replace(/\n/g, " ");
  const out = await $`nvim --headless -c "lua ${lua}" +q 2>&1`.text();
  const lines = out.trim().split("\n").filter(l => l.match(/^\s*[\d.]+\s*ms/));
  if (lines.length) for (const line of lines) console.log("  " + line);
  else console.log("  No plugin load times recorded (all lazy-loaded)");
} catch { console.log("  Could not get Lazy profile"); }

// Summary
sec("Summary");
const loaderEnabled = (await $`nvim --headless -c "lua print(vim.loader.enabled and 'yes' or 'no')" +q 2>&1`.text()).includes("yes");
console.log(`  vim.loader:    ${loaderEnabled ? "enabled ✓" : "disabled ✗"}`);
const msg = avg < 50 ? "Excellent!" : avg < 100 ? "Good" : avg < 200 ? "Could be faster" : "Consider optimizing";
(avg < 100 ? consola.success : avg < 200 ? consola.warn : consola.error)(`Startup time: ${avg.toFixed(1)}ms - ${msg}`);

await $`rm -f ${STARTUP_LOG}`.nothrow();
