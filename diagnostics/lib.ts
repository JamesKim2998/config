import { $ } from "bun";
import { consola } from "consola";

export const MACMINI_DEST = process.env.MACMINI_DEST!;
export const MACMINI_SSH_KEY = process.env.MACMINI_SSH_KEY!.replace("~", process.env.HOME!);
export const MACMINI_HOST = MACMINI_DEST.split("@")[1];

/** Run command on remote via SSH */
export async function ssh(cmd: string): Promise<string> {
  const result = await $`/usr/bin/ssh -i ${MACMINI_SSH_KEY} ${MACMINI_DEST} ${cmd}`.quiet().nothrow();
  return result.text();
}

/** Grep pattern in remote file */
export async function sshGrep(pattern: string, file: string): Promise<boolean> {
  const out = await ssh(`grep -q '${pattern}' ${file} 2>/dev/null && echo OK`);
  return out.includes("OK");
}

/** Print check result */
export function check(name: string, ok: boolean, note?: string): boolean {
  const msg = note ? `${name} — ${note}` : name;
  ok ? consola.success(msg) : consola.fail(msg);
  return ok;
}

/** Print section header */
export function header(title: string) {
  consola.box(title);
}

/** Print subsection */
export function section(num: number, title: string) {
  console.log();
  consola.info(`[${num}] ${title}`);
  console.log();
}
