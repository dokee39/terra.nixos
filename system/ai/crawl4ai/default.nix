{ config, pkgs, lib, ... }:

let
  cfg = config.terra.ai.crawl4ai;
in {
  options.terra.ai.crawl4ai = {
    enable = lib.mkEnableOption "crawl4ai";
    port = lib.mkOption {
      type = lib.types.port;
      default = 11235;
    };
    shmSize = lib.mkOption {
      type = lib.types.str;
      default = "2g";
    };
    adapter.port = lib.mkOption {
      type = lib.types.port;
      default = 3002;
    };
    mcp-wrapper = {
      model = lib.mkOption {
        type = lib.types.str;
        default = "deepseek-v4-flash";
      };
      apiBase = lib.mkOption {
        type = lib.types.str;
        default = "https://api.deepseek.com/v1";
      };
      apiKey_secretFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          Path to a secret file containing the LLM API key for web_research.
          ```
            xxx
          ```
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      crawl4ai = {
        image = "docker.io/unclecode/crawl4ai:latest";
        environment = config.terra.virtualisation.proxyEnv;
        ports = [ "${toString cfg.port}:11235" ];
        autoRemoveOnStop = false;
        extraOptions = [
          "--shm-size=${cfg.shmSize}"
          "--restart=unless-stopped"
          "--label=io.containers.autoupdate=registry"
        ];
      };
    };

    systemd.services.crawl4ai-adapter = let
      pythonEnv = pkgs.python3.withPackages (ps: with ps; [
        fastapi
        uvicorn
        httpx
      ]);
    in  {
      description = "Firecrawl-to-Crawl4AI API Adapter";
      after = [ "podman-crawl4ai.service" ];
      requires = [ "podman-crawl4ai.service" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        CRAWL4AI_BASE_URL = "http://localhost:${toString cfg.port}";
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pythonEnv}/bin/uvicorn adapter:app --app-dir ${dirOf ./adapter.py} --host localhost --port ${toString cfg.adapter.port}";
        Restart = "always";
        RestartSec = 5;
        DynamicUser = true;
        NoNewPrivileges = true;
      };
    };

    age.secrets.crawl4ai-wrapper-llm-api-key = {
      file = cfg.mcp-wrapper.apiKey_secretFile;
      group = config.terra.ai.mcp.groupName;
      mode = "0440";
    };

    terra.ai.mcp.servers.crawl4ai = let
      pythonEnv = pkgs.python3.withPackages (ps: with ps; [
        httpx
        mcp
        openai
      ]);
      crawl4ai-mcp-wrapper = pkgs.writeShellScriptBin "crawl4ai-mcp-wrapper" ''
        export CRAWL4AI_WRAPPER_LLM_API_KEY="$(cat ${config.age.secrets.crawl4ai-wrapper-llm-api-key.path})"
        exec ${pythonEnv}/bin/python ${./mcp-wrapper.py} $@
      '';
    in  {
      type = "stdio";
      command = "${crawl4ai-mcp-wrapper}/bin/crawl4ai-mcp-wrapper";
      args = [
          "--port ${toString cfg.port}"
          "--model ${cfg.mcp-wrapper.model}"
          "--api-base ${cfg.mcp-wrapper.apiBase}"
      ];
    };
  };
}
