{ pkgs, sources, ... }:

let
  duckduckgo-mcp-server-pkg = pkgs.python3Packages.buildPythonPackage {
    pname = "duckduckgo-mcp-server";
    version = sources.duckduckgo-mcp-server.version;
    src = pkgs.fetchFromGitHub {
      owner = sources.duckduckgo-mcp-server.owner;
      repo  = sources.duckduckgo-mcp-server.repo;
      rev   = sources.duckduckgo-mcp-server.rev;
      hash  = sources.duckduckgo-mcp-server.hash;
    };

    pyproject = true;
    build-system = [ pkgs.python3Packages.hatchling ];
    dependencies = with pkgs.python3Packages; [
      beautifulsoup4
      httpx
      httpcore
      mcp
      typer
      rich
      starlette
      uvicorn
      curl-cffi
    ];
    doCheck = false;
  };

  web-tool = pkgs.python3Packages.buildPythonApplication {
    pname = "web-tool";
    version = "0.1.0";
    src = ./.;
    pyproject = true;
    build-system = [ pkgs.python3Packages.hatchling ];
    dependencies = [
      duckduckgo-mcp-server-pkg
      pkgs.python3Packages.curl-cffi
      pkgs.python3Packages.trafilatura
    ];
  };
in {
  home.packages = [ web-tool ];
}
