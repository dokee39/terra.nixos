{ ... }:

{
  imports = [
    ./librechat.nix
    ./meilisearch.nix
    ./mongodb.nix
    ./mcp.nix
    ./mcp-web
    ./mcp-github.nix
  ];
}
