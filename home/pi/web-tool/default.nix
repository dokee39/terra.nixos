{ pkgs, sources, ... }:

let
  # HACK: nixpkgs only has mcp 1.x; duckduckgo-mcp-server 0.7 needs the 2.x API.
  # Local mcp + mcp-types builds until NixOS/nixpkgs#556839 and its dependent-package chain land.
  mcp-sdk-src = pkgs.fetchFromGitHub {
    owner = sources.mcp-sdk.owner;
    repo  = sources.mcp-sdk.repo;
    rev   = sources.mcp-sdk.rev;
    hash  = sources.mcp-sdk.hash;
  };

  mcp-types-pkg = pkgs.python3Packages.buildPythonPackage {
    pname = "mcp-types";
    version = sources.mcp-sdk.version;
    src = mcp-sdk-src;
    sourceRoot = "${mcp-sdk-src.name}/src/mcp-types";
    pyproject = true;
    build-system = with pkgs.python3Packages; [ hatchling uv-dynamic-versioning ];
    dependencies = with pkgs.python3Packages; [ pydantic typing-extensions ];
    doCheck = false;
  };

  mcp-pkg = pkgs.python3Packages.buildPythonPackage {
    pname = "mcp";
    version = sources.mcp-sdk.version;
    src = mcp-sdk-src;
    pyproject = true;
    build-system = with pkgs.python3Packages; [ hatchling uv-dynamic-versioning ];
    dependencies = with pkgs.python3Packages; [
      anyio
      httpx2
      jsonschema
      mcp-types-pkg
      opentelemetry-api
      pydantic
      pyjwt
      python-multipart
      sse-starlette
      starlette
      typing-extensions
      typing-inspection
      uvicorn
    ];
    doCheck = false;
  };

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
      mcp-pkg
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
