import { $ } from "bun";
import { ssh, check, header, section, macmini, macminiHost } from "./lib";

header(`Mac Mini Latency Diagnostic\nTarget: ${macmini}`);

// --- Ping ---
section(1, "Network Latency");

const ping = await $`ping -c 10 ${macminiHost}`.quiet().nothrow().text();
const times = [...ping.matchAll(/time=(\d+\.?\d*)/g)].map(m => parseFloat(m[1]));

if (times.length) {
  const avg = times.reduce((a, b) => a + b) / times.length;
  const max = Math.max(...times);
  const min = Math.min(...times);
  const std = Math.sqrt(times.reduce((sum, t) => sum + (t - avg) ** 2, 0) / times.length);

  console.log(`  Ping (10 samples): min/avg/max = ${min.toFixed(1)}/${avg.toFixed(1)}/${max.toFixed(1)} ms`);
  check("Avg < 20ms", avg < 20, `${avg.toFixed(1)}ms`);
  check("Max < 50ms", max < 50, `${max.toFixed(1)}ms`);
  check("Stable (stddev < 10ms)", std < 10, `${std.toFixed(1)}ms`);
}

// --- Network interface ---
section(2, "Network Interface");

const route = await ssh("route -n get default 2>/dev/null | grep interface");
const iface = route.trim().split(/\s+/).pop() || "unknown";
const hwPorts = await ssh(`networksetup -listallhardwareports | grep -B 1 '${iface}' | head -1`);
const isEthernet = hwPorts.includes("Ethernet");
check("Using Ethernet", isEthernet, `${iface}`);

// --- Power management ---
section(3, "Power Management");

const pmset = await ssh("pmset -g");
const getSetting = (name: string) => pmset.match(new RegExp(`${name}\\s+(\\d+)`))?.[1] || "?";

check("sleep = 0", getSetting("sleep") === "0", `sleep = ${getSetting("sleep")}`);
check("womp = 1 (Wake on LAN)", getSetting("womp") === "1", `womp = ${getSetting("womp")}`);
check("ttyskeepawake = 1", getSetting("ttyskeepawake") === "1");

// --- SSH config ---
section(4, "SSH ControlMaster");

const sshConfig = await Bun.file(`${process.env.HOME}/.ssh/config`).text().catch(() => "");
check("SSH config for macmini", sshConfig.toLowerCase().includes("macmini"));
check("ControlMaster configured", sshConfig.includes("ControlMaster"));
