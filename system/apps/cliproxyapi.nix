{ config, ... }:

{
  age.secrets.cliproxyapi-api-key = {
    file = ../../secrets/cliproxyapi-api-key.age;
    owner = config.terra.userName;
  };
  age.secrets.cliproxyapi-panel-key.file =
    ../../secrets/cliproxyapi-panel-key.age;
  age.secrets.deepseek-api-key.file =
    ../../secrets/deepseek-api-key.age;

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
          priority = -20;
          keys = [ { api-key._secret = config.age.secrets.deepseek-api-key.path; } ];
          models = [
            {
              name = "deepseek-flash";
              alias = "flash";
            }
          ];
        }
      ];
      oauth.model-alias = {
        antigravity = [
          {
            name = "gemini-4-hydrogen-xhigh";
            alias = "flash";
            fork = true;
          }
        ];
        codex = [
          {
            name = "gpt-6-luna";
            alias = "flash";
            fork = true;
          }
        ];
      };
    };
  };
}
