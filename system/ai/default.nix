{ pkgs, ... }:

{
  imports = [
    ./librechat.nix
    ./searxng.nix
    ./crawl4ai
    ./meilisearch.nix
    ./mongodb.nix
    ./mcp.nix
    ./mcp-github.nix
    ./jina-reranker
  ];

  environment.systemPackages = with pkgs; [
    cc-switch
  ];
}
