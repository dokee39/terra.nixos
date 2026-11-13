{ pkgs, ... }:

let
  pichat = pkgs.writeShellScriptBin "pichat" ''
    args=(); here=
    for a; do [ "$a" = "--here" ] && here=1 || args+=("$a"); done
    [ "$here" ] || cd /tmp
    pi --append-system-prompt ${./APPEND_SYSTEM.md} \
       --append-system-prompt ${./chat-instruction.md} \
       "''${args[@]}"
  '';
in
{
  imports = [ ./web-tool ];

  programs.pi-coding-agent = {
    enable = true;
    extraPackages = [ pkgs.nodejs ];

    settings = {
      quietStartup = true;
      collapseChangelog = true;

      enableInstallTelemetry = false;
      enableAnalytics = false;

      defaultProvider = "google-antigravity";
      defaultModel = "gemini-4-hydrogen";
      defaultThinkingLevel = "high";

      autocompleteMaxVisible = 10;

      packages = [
        "npm:@firstpick/pi-themes-bundle"
        "npm:@aliou/pi-guardrails"
        "npm:@sherif-fanous/pi-rtk"
        "npm:@narumitw/pi-usage"
        "npm:@justjoshn/pi-antigravity-oauth"
      ];

      theme = "rose-pine";
    };
  };

  home.packages = [ pkgs.rtk pichat ];

  home.sessionVariables = {
    PI_SKIP_VERSION_CHECK  = "1";
  };

  home.file.".pi/agent/APPEND_SYSTEM.md".source = ./APPEND_SYSTEM.md;
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
