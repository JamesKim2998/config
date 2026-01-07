import { consola } from "consola";
import { ssh, check } from "./lib";

consola.info("OSC 52 Clipboard Diagnostic\n");

const b64 = btoa("TEST");
const out = await ssh(`printf '\\033]52;c;${b64}\\007'`);
check("Direct OSC 52", out.includes("]52") || out.includes("\x1b]52"));

check("osc52-copy script", (await ssh("test -x ~/.local/bin/osc52-copy && echo OK")).includes("OK"));
check("pbcopy alias", (await ssh("grep -q 'pbcopy.*osc52' ~/.zshrc && echo OK")).includes("OK"));
