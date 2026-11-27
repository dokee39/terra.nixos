{ config, pkgs, ... }:

{
  age.secrets.cliproxyapi-api-key = {
    file = ../../secrets/cliproxyapi-api-key.age;
    owner = config.terra.userName;
  };
  age.secrets.cliproxyapi-panel-key.file =
    ../../secrets/cliproxyapi-panel-key.age;
  age.secrets.deepseek-api-key.file =
    ../../secrets/deepseek-api-key.age;
  age.secrets.google-ai-studio-api-key.file =
    ../../secrets/google-ai-studio-api-key.age;

  services.cliproxyapi = {
    enable = true;
    settings = {
      server.host = "127.0.0.1";
      observability.logs.logging-to-file = true;
      access.api-keys = [
        { _secret = config.age.secrets.cliproxyapi-api-key.path; }
      ];
      management.secret-key._secret =
        config.age.secrets.cliproxyapi-panel-key.path;
      multimedia.disable-image-generation = "passthrough";
      api-keys.openai-compatibility = [
        {
          name = "deepseek";
          base-url = "https://api.deepseek.com";
          priority = -50;
          keys = [ { api-key._secret = config.age.secrets.deepseek-api-key.path; } ];
          models = [
            {
              name = "deepseek-flash";
              alias = "flash";
            }
            {
              name = "deepseek-flash";
              alias = "translate";
            }
          ];
        }
      ];
      api-keys.gemini = [
        {
          name = "google-ai-studio";
          priority = -100;
          keys = [ { api-key._secret = config.age.secrets.google-ai-studio-api-key.path; } ];
          models = [
            {
              name = "gemini-4-hydrogen";
              alias = "flash";
            }
            {
              name = "gemini-4-neon";
              max-context-length = 1048576;
              thinking.levels = [ "low" "medium" "high" "xhigh" ];
            }
          ];
        }
        {
          name = "google-ai-studio-translate";
          priority = 50;
          keys = [ { api-key._secret = config.age.secrets.google-ai-studio-api-key.path; } ];
          prefix = "kiss";
          models = [
            {
              name = "gemini-4-hydrogen";
              alias = "translate";
            }
          ];
        }
      ];
      oauth.model-alias = {
        codex = [
          {
            name = "gpt-6-luna";
            alias = "flash";
            fork = true;
          }
          {
            name = "gpt-6-luna";
            alias = "translate";
            fork = true;
          }
        ];
      };
    };
  };

  systemd.timers.cliproxyapi-quota-warmup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "55min";
    };
  };

  systemd.services.cliproxyapi-quota-warmup = {
    after = [ "cliproxyapi.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = config.terra.userName;
    };

    script = ''
      for model in gpt-6-luna; do
        ${pkgs.curl}/bin/curl --silent --show-error --fail --max-time 60 --output /dev/null \
          --variable 'api_key@${config.age.secrets.cliproxyapi-api-key.path}' \
          --expand-header 'Authorization: Bearer {{api_key:trim}}' \
          --json "$(printf '{"model":"%s","messages":[{"role":"user","content":"Reply OK."}]}' "$model")" \
          'http://127.0.0.1:${toString config.services.cliproxyapi.settings.server.port}/v1/chat/completions' || continue
      done
    '';
  };
}
