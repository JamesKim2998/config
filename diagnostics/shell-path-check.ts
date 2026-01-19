import { $ } from "bun";
import { consola } from "consola";
import { check, header, section, macmini } from "./lib";

header(`PATH Diagnostic\nLocal + Remote (${macmini})`);

// Shell modes: -l = login (.zprofile), -i = interactive (.zshrc)
type ShellMode = "default" | "login" | "interactive" | "login+interactive";
const shellFlags: Record<ShellMode, string> = {
  "default": "",
  "login": "-l",
  "interactive": "-i",
  "login+interactive": "-il",
};

// Targets
type Target = "local" | "remote";
async function run(target: Target, cmd: string): Promise<boolean> {
  const result = target === "local"
    ? await $`sh -c ${cmd}`.quiet().nothrow()
    : await $`ssh ${macmini} ${cmd}`.quiet().nothrow();
  return result.exitCode === 0;
}

// Check if command exists in given shell mode
async function checkCmd(target: Target, mode: ShellMode, cmd: string): Promise<boolean> {
  const flags = shellFlags[mode];
  const shellCmd = flags ? `zsh ${flags} -c 'type ${cmd}'` : `which ${cmd}`;
  return run(target, shellCmd);
}

// Tools to check per shell mode
const checks: { mode: ShellMode; cmds: string[] }[] = [
  { mode: "login", cmds: ["nvim", "fzf", "rg", "fd", "bat", "eza", "zoxide", "yazi", "lazygit", "bun", "starship"] },
  { mode: "login+interactive", cmds: ["z"] },
];

const results: Record<Target, number> = { local: 0, remote: 0 };
let total = 0;
let sectionNum = 0;
const sec = (title: string) => section(++sectionNum, title);

for (const target of ["local", "remote"] as Target[]) {
  for (const { mode, cmds } of checks) {
    sec(`${target} (${mode})`);
    for (const cmd of cmds) {
      const ok = await checkCmd(target, mode, cmd);
      if (ok) results[target]++;
      if (target === "local") total++;
      check(cmd, ok);
    }
  }
}

sec("Summary");
console.log(`  Local:  ${results.local}/${total}`);
console.log(`  Remote: ${results.remote}/${total}`);

if (results.local === total && results.remote === total) {
  consola.success("All checks passed!");
}
