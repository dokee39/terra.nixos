{ pkgs, ... }:

{
  imports = [
    ./librechat.nix
    ./meilisearch.nix
    ./mongodb.nix
    ./mcp.nix
    ./mcp-web
    ./mcp-github.nix
  ];

  environment.systemPackages = with pkgs; [
    cc-switch
    llm-agents.omp
  ];
}
