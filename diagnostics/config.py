"""Shared config for diagnostic scripts."""

import os
import subprocess

MACMINI_DEST = os.environ["MACMINI_DEST"]
MACMINI_SSH_KEY = os.path.expanduser(os.environ["MACMINI_SSH_KEY"])


def ssh(cmd, timeout=10, text=True):
    """Run command on remote via SSH."""
    try:
        r = subprocess.run(
            ["/usr/bin/ssh", "-i", MACMINI_SSH_KEY, MACMINI_DEST, cmd],
            capture_output=True, timeout=timeout, text=text
        )
        return r.stdout + r.stderr, r.returncode
    except Exception as e:
        return str(e) if text else str(e).encode(), 1


def ssh_grep(pattern, file, quiet=False):
    """Grep pattern in remote file. Returns (output, found)."""
    flag = "-q" if quiet else ""
    out, code = ssh(f"grep {flag} '{pattern}' {file} 2>/dev/null && echo OK")
    return out, "OK" in out


def check(name, ok, note=""):
    """Print check result."""
    status = "OK" if ok else "FAIL"
    suffix = f" — {note}" if note else ""
    print(f"  {status} {name}{suffix}")
    return ok
