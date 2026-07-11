{ pkgs, osConfig, ... }:

{
  programs.pi-coding-agent = {
    enable = true;

    extraPackages = [ pkgs.nodejs ];

    settings = {
      quietStartup = true;
      collapseChangelog = true;

      enableInstallTelemetry = false;
      enableAnalytics = false;

      defaultProvider = "deepseek";
      defaultModel = "deepseek-v4-flash";
      defaultThinkingLevel = "high";

      autocompleteMaxVisible = 10;

      packages = [
        "npm:@firstpick/pi-themes-bundle"
        "npm:@ayulab/pi-rewind"
        "npm:@aliou/pi-guardrails"
        "npm:pi-mcp-adapter"
        "npm:pi-rtk-optimizer"
        "npm:pi-cache-optimizer"
        "npm:@juicesharp/rpiv-btw"
      ];

      theme = "rose-pine";
    };
  };

  home.packages = let                                                                            
    pichat = pkgs.writeShellScriptBin "pichat" ''
      origin_cwd="$(pwd)"
      cd /tmp
      pi --session-dir ~/.pi/chat-sessions \
         --append-system-prompt ${./APPEND_SYSTEM.md} \
         --append-system-prompt ${./chat-instruction.md} \
         "$@"
      cd "$origin_cwd"
    '';
  in [ pkgs.rtk pichat ];

  home.sessionVariables = {
    PI_SKIP_VERSION_CHECK  = "1";
  };

  home.file.".pi/agent/APPEND_SYSTEM.md".source = ./APPEND_SYSTEM.md;
  home.file.".pi/agent/models.json".source = ./models.json;
  home.file.".pi/agent/mcp.json".text = builtins.toJSON {
    mcpServers = (removeAttrs osConfig.terra.ai.mcp.servers [ "github" ]);
  };

  home.file.".pi/agent/skills" = {
    source = ./skills;
    recursive = true;
  };
  home.file.".pi/agent/prompts" = {
    source = ./prompts;
    recursive = true;
  };
}
