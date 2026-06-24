{ config, pkgs, lib, inputs, ... }:

let
  cfg = config.terra.ai.mcp.web;
  duckduckgo-mcp-server-pkg = pkgs.python3Packages.buildPythonPackage {
    pname = "duckduckgo-mcp-server";
    version = "unstable-${inputs.duckduckgo-mcp-server.lastModifiedDate}";
    src = inputs.duckduckgo-mcp-server;
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
in {
  options.terra.ai.mcp.web = {
    enable = lib.mkEnableOption "web-mcp (stdio)";

    crawl4aiPort = lib.mkOption {
      type = lib.types.port;
      default = 11235;
      description = "crawl4ai container port";
    };

    shmSize = lib.mkOption {
      type = lib.types.str;
      default = "2g";
    };

    env_secretFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        File containing:
          CRAWL4AI_API_TOKEN=xxx
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.crawl4ai-env = {
      file = cfg.env_secretFile;
      group = config.terra.ai.mcp.groupName;
      mode = "0440";
    };

    virtualisation.oci-containers.containers.crawl4ai = {
      image = "docker.io/unclecode/crawl4ai:latest";
      environment = config.terra.virtualisation.proxyEnv;
      environmentFiles = [ config.age.secrets.crawl4ai-env.path ];
      ports = [ "${toString cfg.crawl4aiPort}:11235" ];
      autoRemoveOnStop = false;
      extraOptions = [
        "--shm-size=${cfg.shmSize}"
        "--restart=unless-stopped"
        "--label=io.containers.autoupdate=registry"
      ];
    };

    terra.ai.mcp.servers.web = let
      pythonEnv = pkgs.python3.withPackages (ps: [
        duckduckgo-mcp-server-pkg
        ps.httpx
        ps.mcp
      ]);
      webMcpScript = pkgs.writeShellScriptBin "web-mcp" ''
        set -a
        source "${config.age.secrets.crawl4ai-env.path}"
        set +a
        exec ${pythonEnv}/bin/python ${./.}/server.py
      '';
    in {
      type = "stdio";
      command = "${webMcpScript}/bin/web-mcp";
      args = [];
      env = {
        DDG_SAFE_SEARCH = "STRICT";
        DDG_REGION = "us-en";
        CRAWL4AI_BASE = "http://localhost:${toString cfg.crawl4aiPort}";
      };
    };
  };
}
