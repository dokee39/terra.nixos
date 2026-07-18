{ pkgs, lib, ... }:

let
  pi-wrapper = pkgs.writeShellScriptBin "pi" ''
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      exec ${lib.getExe pkgs.pi-coding-agent} --extension npm:@ayulab/pi-rewind  "$@"
    else
      exec ${lib.getExe pkgs.pi-coding-agent} "$@"
    fi
  '';
  pichat = pkgs.writeShellScriptBin "pichat" ''
    args=(); here=
    for a; do [ "$a" = "--here" ] && here=1 || args+=("$a"); done
    [ "$here" ] || cd /tmp
    pi --append-system-prompt ${./APPEND_SYSTEM.md} \
       --append-system-prompt ${./chat-instruction.md} \
       "''${args[@]}"
    [ "$here" ] || cd - > /dev/null
  '';
in
{
  imports = [ ./web-tool ];

  programs.pi-coding-agent = {
    enable = true;
    package = pi-wrapper;
    extraPackages = [ pkgs.nodejs ];

    settings = {
      quietStartup = true;
      collapseChangelog = true;

      enableInstallTelemetry = false;
      enableAnalytics = false;

      defaultProvider = "openai-codex";
      defaultModel = "gpt-5.6-luna";
      defaultThinkingLevel = "high";

      autocompleteMaxVisible = 10;

      packages = [
        "npm:@firstpick/pi-themes-bundle"
        "npm:@aliou/pi-guardrails"
        "npm:pi-rtk-optimizer"
        "npm:pi-cache-optimizer"
      ];

      theme = "rose-pine";
    };
  };

  home.packages = [ pkgs.rtk pichat ];

  home.sessionVariables = {
    PI_SKIP_VERSION_CHECK  = "1";
  };

  home.file.".pi/agent/APPEND_SYSTEM.md".source = ./APPEND_SYSTEM.md;
  home.file.".pi/agent/models.json".source = ./models.json;
  home.file.".pi/agent/extensions/web-tools.ts".source = ./extensions/web-tools.ts;
  home.file.".pi/agent/skills" = {
    source = ./skills;
    recursive = true;
  };
  home.file.".pi/agent/prompts" = {
    source = ./prompts;
    recursive = true;
  };
}
