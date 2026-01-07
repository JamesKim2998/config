import { existsSync } from "fs";
import { consola } from "consola";
import { ssh, sshGrep, check } from "./lib";

consola.info("sv() cd-on-exit Diagnostic\n");

check("SSH connection", (await ssh("echo OK")).includes("OK"));
check("zshexit hook", await sshGrep("zshexit.*sv_last_dir", "~/.zshrc"));

const path = (await ssh("cat ~/.sv_last_dir 2>/dev/null")).trim();
check("~/.sv_last_dir", !!path, path || "(empty)");
if (path) check("Local path exists", existsSync(path));

console.log("\n--- Flow ---");
console.log("1. zshexit() saves pwd on shell exit");
console.log("2. sv() reads ~/.sv_last_dir and cd's locally");
