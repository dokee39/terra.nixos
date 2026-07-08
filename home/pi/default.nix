{ pkgs, osConfig, ... }:

{
  home.packages = [ pkgs.rtk ];
  home.sessionVariables = {
    PI_SKIP_VERSION_CHECK  = "1";
  };

  programs.pi-coding-agent = {
    enable = true;

    extraPackages = [ pkgs.nodejs ];

    settings = {
      quietStartup = true;
      collapseChangelog = true;

      enableInstallTelemetry = false;
      enableAnalytics = false;

      defaultProvider = "opencode-go";
      defaultModel = "glm-5.2";
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
