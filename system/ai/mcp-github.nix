{ config, pkgs, lib, ... }:

let
  cfg = config.terra.ai.mcp.github;
in
{
  options.terra.ai.mcp.github = {
    enable = lib.mkEnableOption "GitHub MCP Server (stdio)";
    pat_secretFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a secret file containing the GitHub personal access token.
        ```
          github_pat_xxx
        ```
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.mcp-github-pat = {
      file = cfg.pat_secretFile;
      group = config.terra.ai.mcp.groupName;
      mode = "0440";
    };

    terra.ai.mcp.servers.github = let
      github-mcp-wrapper = pkgs.writeShellScriptBin "github-mcp-server-wrapper" ''
        export GITHUB_PERSONAL_ACCESS_TOKEN="$(cat ${config.age.secrets.mcp-github-pat.path})"
        exec ${pkgs.github-mcp-server}/bin/github-mcp-server $@
      '';
    in  {
      type = "stdio";
      command = "${github-mcp-wrapper}/bin/github-mcp-server-wrapper";
      args = [ 
        "stdio" 
        "--read-only" 
        "--toolsets" 
        "repos,git,labels,issues,pull_requests,discussions"
      ];
    };
  };
}
