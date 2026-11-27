import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  async function notify(message: string) {
    await Promise.all([
      pi.exec("notify-send", ["Pi", message]),
      process.stdout.write("\x07")
    ]);
  }

  pi.on("agent_settled", () => notify("Ready for input"));
  pi.on("ui_prompt_start", () => notify("Waiting for input"));
}
