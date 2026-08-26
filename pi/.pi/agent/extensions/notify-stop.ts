import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";
import { basename } from "node:path";

function tmuxWindowName(pane: string): Promise<string | undefined> {
  return new Promise((resolve) => {
    execFile(
      "tmux",
      ["display-message", "-t", pane, "-p", "#W"],
      (err, stdout) => resolve(err ? undefined : stdout.trim() || undefined),
    );
  });
}

export default function (pi: ExtensionAPI) {
  pi.on("agent_settled", async (_event, ctx) => {
    if (!ctx.isIdle()) return;

    const dirName = basename(ctx.cwd.replace(/\/+$/, "")) || ctx.cwd;
    const tmuxPane = process.env.TMUX_PANE;
    const win = tmuxPane ? await tmuxWindowName(tmuxPane) : undefined;
    const label = win ? `${win}, ${dirName}` : dirName;

    execFile("notify-send", [
      "-u", "normal", "-t", "0", "-a", "pi", "pi",
      `Agent finished work in ${label}`,
    ], () => {});
  });
}
