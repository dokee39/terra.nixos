{ config, lib, pkgs, inputs, ... }:

let
  pythonEnv = pkgs.python3.withPackages (p: [
    p.transformers
    p.torch
    p.fastapi
    p.uvicorn
    p.pydantic
  ]);
  serverScript = pkgs.writeTextFile {
    name = "jina-reranker-server.py";
    executable = true;
    text = builtins.readFile ./server.py;
  };
in

{
  options.terra.ai.jina-reranker = {
    enable = lib.mkEnableOption "Jina Reranker v3 local API service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8086;
    };
    idleTimeout = lib.mkOption {
      type = lib.types.int;
      default = 300;
      description = "Seconds of inactivity before offloading model from GPU to CPU.";
    };
  };

  config = lib.mkIf config.terra.ai.jina-reranker.enable {
    nixpkgs.config.cudaSupport = true;

    systemd.services.jina-reranker = {
      description = "Jina Reranker v3 API";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        JINA_MODEL_PATH = pkgs.fetchgit {
          url = "https://huggingface.co/jinaai/jina-reranker-v3";
          rev = inputs.jina-reranker-v3.rev;
          hash = "sha256-kBopYrjtWW+U4IVyDhv0i547ab1/syo3KHlb5l1a1Fo=";
          fetchLFS = true;
        };
        SERVER_PORT = toString config.terra.ai.jina-reranker.port;
        IDLE_TIMEOUT = toString config.terra.ai.jina-reranker.idleTimeout;
        HF_HOME = "/var/lib/jina-reranker";
      };

      serviceConfig = {
        ExecStart = "${pythonEnv}/bin/python ${serverScript}";
        Restart = "always";
        RestartSec = 10;
        DynamicUser = true;
        StateDirectory = "jina-reranker";
        SupplementaryGroups = [ "video" "render" ];
        ProtectSystem = true;
        ProtectHome = true;
      };
    };
  };
}
