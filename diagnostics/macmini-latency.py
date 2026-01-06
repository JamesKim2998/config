#!/usr/bin/env python3
"""Mac Mini network latency diagnostic.

Checks power management settings and network latency that affect SSH performance.
"""

import subprocess
import statistics
from config import ssh, check, MACMINI_DEST

print("=" * 60)
print("Mac Mini Latency Diagnostic")
print(f"Target: {MACMINI_DEST}")
print("=" * 60)

# --- Ping latency test ---
print("\n[1] Network Latency\n")

ip = MACMINI_DEST.split("@")[1]
try:
    r = subprocess.run(
        ["ping", "-c", "10", ip],
        capture_output=True, text=True, timeout=15
    )
    lines = [l for l in r.stdout.splitlines() if "time=" in l]
    times = [float(l.split("time=")[1].split()[0]) for l in lines]

    if times:
        avg = statistics.mean(times)
        std = statistics.stdev(times) if len(times) > 1 else 0
        max_t = max(times)
        min_t = min(times)

        print(f"  Ping results (10 samples):")
        print(f"    min/avg/max = {min_t:.1f}/{avg:.1f}/{max_t:.1f} ms")
        print(f"    stddev = {std:.1f} ms")

        check("Avg latency < 20ms", avg < 20, f"{avg:.1f}ms")
        check("Max latency < 50ms", max_t < 50, f"{max_t:.1f}ms")
        check("Stable (stddev < 10ms)", std < 10, f"{std:.1f}ms")

        if max_t > 50 and min_t < 20:
            print("\n  ⚠ High variance detected - likely WiFi power saving")
except Exception as e:
    print(f"  Ping failed: {e}")

# --- Network interface ---
print("\n[2] Network Interface\n")

out, _ = ssh("networksetup -listallhardwareports | grep -A 2 'Wi-Fi\\|Ethernet'")
print(f"  Available interfaces:\n{out}")

out, _ = ssh("route -n get default 2>/dev/null | grep interface")
iface = out.strip().split()[-1] if out.strip() else "unknown"
is_wifi = iface.startswith("en") and iface != "en0"  # en0 is usually WiFi on Mac

out, _ = ssh(f"networksetup -listallhardwareports | grep -B 1 '{iface}' | head -1")
iface_type = "WiFi" if "Wi-Fi" in out else "Ethernet" if "Ethernet" in out else iface
check("Using Ethernet (recommended)", "Ethernet" in out, f"interface: {iface} ({iface_type})")

# --- Power management settings ---
print("\n[3] Power Management (pmset)\n")

out, _ = ssh("pmset -g")
print("  Current settings:")

settings = {}
for line in out.splitlines():
    parts = line.strip().split()
    if len(parts) >= 2:
        settings[parts[0]] = parts[1]

sleep_val = settings.get("sleep", "?")
womp_val = settings.get("womp", "?")
tty_val = settings.get("ttyskeepawake", "?")

check("sleep = 0 (disabled)", sleep_val == "0", f"sleep = {sleep_val}")
check("womp = 1 (Wake on LAN)", womp_val == "1", f"womp = {womp_val}")
check("ttyskeepawake = 1", tty_val == "1", f"ttyskeepawake = {tty_val}")

# --- SSH config check ---
print("\n[4] SSH ControlMaster (local)\n")

try:
    with open("/Users/jameskim/.ssh/config") as f:
        ssh_config = f.read()

    has_macmini_config = "macmini" in ssh_config.lower() or ip in ssh_config
    check("SSH config for macmini exists", has_macmini_config)

    has_controlmaster = "ControlMaster" in ssh_config
    check("ControlMaster configured", has_controlmaster)
except FileNotFoundError:
    print("  ~/.ssh/config not found")

# --- Recommendations ---
print("\n[5] Recommendations\n")

recommendations = []

if sleep_val != "0":
    recommendations.append("sudo pmset -a sleep 0  # Disable system sleep")
if womp_val != "1":
    recommendations.append("sudo pmset -a womp 1   # Enable Wake on LAN")
if tty_val != "1":
    recommendations.append("sudo pmset -a ttyskeepawake 1")

if "Ethernet" not in iface_type:
    recommendations.append("# Consider using Ethernet instead of WiFi")

if recommendations:
    print("  Run on Mac Mini:")
    for r in recommendations:
        print(f"    {r}")
else:
    print("  All settings look good!")

print("")
