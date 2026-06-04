{ config, lib, ... }:

let
  cfg = config.terra.ai.librechat;
  aiCfg = config.terra.ai;
in {
  options.terra.ai.librechat = {
    enable = lib.mkEnableOption "LibreChat service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3080;
    };
    credentials_secretFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a secret file containing the credentials.
        ```
          CREDS_KEY=xxx
          CREDS_IV=xxx
          JWT_SECRET=xxx
          JWT_REFRESH_SECRET=xxx
          MEILI_MASTER_KEY=xxx
          SEARXNG_INSTANCE_URL=https://api.example.com
          SEARXNG_API_KEY=xxx
          FIRECRAWL_API_URL=https://api.example.com
          FIRECRAWL_VERSION=v1
          FIRECRAWL_API_KEY=xxx
          JINA_API_URL=http://api.example.com/v1/rerank
          JINA_API_KEY=xxx
          DEEPSEEK_API_KEY=xxx
          MOONSHOT_API_KEY=xxx
          OPENROUTER_KEY=xxx
        ```
      '';
    };
  };

  config = {
    age.secrets.librechat-credentials.file = cfg.credentials_secretFile;

    users.users.librechat.extraGroups = [ aiCfg.mcp.groupName ];

    services.librechat = {
      enable = true;

      env = {
        PORT = cfg.port;
        SEARCH = true;
        ALLOW_REGISTRATION = false;
        MONGO_URI = "mongodb://localhost:${toString aiCfg.mongodb.port}/LibreChat";
        MEILI_HOST = "http://localhost:${toString aiCfg.meilisearch.port}";
      };
      credentialsFile = config.age.secrets.librechat-credentials.path;

      settings = {
        version = "1.3.9";
        cache = true;

        interface = {
          defaultEndpoint = "DeepSeek";
          defaultModel = "deepseek-v4-flash";
          marketplace.use = false;
          modelSelect = false;
          prompts = false;
          parameters = true;
          memories = false;
          presets = true;
          multiConvo = true;
        };

        memory.disabled = true;

        webSearch = {
          searchProvider = "searxng";
          scraperProvider = "firecrawl";
          rerankerType = "jina";
        };

        mcpSettings.allowedDomains = lib.lists.unique (
          lib.mapAttrsToList (name: server:
            let
              url = server.url or "";
              m = builtins.match "([^/]+://[^/]+).*" url;
            in
              if m == null then url else builtins.head m
          ) config.services.librechat.settings.mcpServers
        );
        mcpServers = lib.mkMerge (
          [ aiCfg.mcp.servers ]
          ++ map (name: { ${name}.serverInstructions = true; })
            (builtins.attrNames aiCfg.mcp.servers)
        );

        summarization = {
          provider = "DeepSeek";
          model = "deepseek-v4-flash";
          parameters = {
            max_tokens = 16384;
            maxContextTokens = 1048576;
            reasoning_effort = "high";
          };
          trigger = {
            type = "token_ratio";
            value = 0.8;
          };
          maxSummaryTokens = 16384;
          reserveRatio = 0.1;
          contextPruning = {
            enabled = true;
            keepLastAssistants = 3;
            softTrimRatio = 0.4;
            hardClearRatio = 0.6;
            minPrunableToolChars = 50000;
          };
        };

        modelSpecs = let
          systemPrompt = ''
            You are a helpful assistant.

            Current Date & Time: {{current_datetime}}

            **CRITICAL:** The following **RULES** are mandatory. Violation of any rule is unacceptable.

            **RULES**:
            ```
            ## Tool Usage
            - The tools described below may not all be enabled. Use only the tools that are actually available, and do not assume the existence of any tool not listed.
            - GitHub code, files, commits, issues, or PRs → Use **GitHub MCP only**. Never use web_fetch, web_search, or any generic tool for github.com / raw.githubusercontent.com URLs.
            - Real-time info or recent unknown sources → `web_search` (fast discovery, results may be truncated).
              Use `site:` operator to restrict search to a specific site or documentation section for precise lookups.
            - Known exact URL needing full page content → `web_fetch`.
            - Extracting a specific type of information from multiple candidate URLs (broad reading across pages) → `web_research`.
              If `web_research` misses needed parts, follow up with `web_fetch` on individual pages.

            ## Answer Style
            - Reply in Chinese unless requested otherwise. Search result language is irrelevant; do not default to English.
            - No quotation marks unless direct quote.
            - No analogies or metaphorical replacements. Lower barriers: start from known facts, introduce one concept at a time, replace jargon or vague terms with precise words.
            - No "not… but…" contrast structures. State final point directly; no negation preamble or rhetorical detours.
            - Do not infer missing facts or intended behavior. Verify with tools; if unverifiable, state so directly.
            - Do not question user statements unless clear factual error exists. Follow user instructions directly. If necessary, add a one‑sentence note at the end only.
            - Do not expand details or force a summary unless explicitly requested.
            - Give one best solution when multiple options not requested. Briefly mention alternatives only when clearly necessary.
            - Concise, direct answers. Short sentences. Omit padding, repetition, summaries, pleasantries, or transition phrases. No explanatory commentary unless user explicitly asks for it.
            - When researching implementations, personal/small projects can be references. For long‑term deployment, recommend only widely adopted community open‑source projects.

            ## Coding Principles
            - **Research & Verification**
              - Use built‑in search or MCP to find relevant implementations when needed.
              - For comparing implementations, code structure, or patterns, prefer GitHub MCP.
              - Do not infer missing facts. Verify with available tools.
              - Prioritize official documentation and widely recognized community sources over low‑quality or unverified results.
            - **Structural Principles**
              - Define the problem before changing code. Fix root cause, not symptom.
              - Prioritize correct structure over minimal diffs. Do not preserve bad patterns to avoid touching code.
              - Design with foreseeable extensions in mind. Prefer extensible structures over one‑off designs.
              - Allow small adjustments that improve consistency. Do not preserve duplication or special cases just to avoid touching more code.
            - **Coding Style**
              - Keep changes consistent with existing project style and conventions.
              - Use a concise, straightforward style. Do not abstract or split simple logic without clear justification.
              - Comments in English. No comments unless necessary or explicitly requested.
            ```

            **CRITICAL:** Before outputting the results, please ensure that your answer follows the **RULES** above. Violation of any rule is unacceptable.
          '';
          deepseekPreset = {
            endpoint = "DeepSeek";
            promptPrefix = systemPrompt;
            reasoning_effort = "xhigh";
            max_tokens = 48000;
            maxContextTokens = 1048576;
          };
        in {
          list = [
            {
              name = "DeepSeek V4 Flash";
              label = "DeepSeek V4 Flash";
              default = true;
              preset = lib.mkMerge [
                deepseekPreset
                { model = "deepseek-v4-flash"; }
              ];
            }
            {
              name = "DeepSeek V4 Pro";
              label = "DeepSeek V4 Pro";
              preset = lib.mkMerge [
                deepseekPreset
                { model = "deepseek-v4-pro"; }
              ];
            }
          ];
        };

        endpoints = {
          all = {
            titleConvo = true;
            titleEndpoint = "DeepSeek";
            titleModel = "deepseek-v4-flash";
            titlePromptTemplate = "Conversation:\nUser: {input}\nAI: {output}";
            titlePrompt = ''
              Analyze the conversation below and output only a very short title that summarizes the user's question.
              The title must be written in the detected language of the conversation, without punctuation or quotation marks.
              - If the language uses spaces between words (e.g., English), limit the title to 5 words.
              - If the language does not use spaces between words (e.g., Chinese), limit the title to 12 characters.

              {convo}
            '';
          };

          agents = {
            recursionLimit = 80;
            maxRecursionLimit = 200;
            maxCitations = 10;
            maxCitationsPerFile = 5;
            minRelevanceScore = 0.6;
          };

          custom = [
            {
              name = "DeepSeek";
              apiKey = "\${DEEPSEEK_API_KEY}";
              baseURL = "https://api.deepseek.com/v1";
              models = {
                default = [ "deepseek-v4-pro" "deepseek-v4-flash" ];
                fetch = true;
              };
              modelDisplayLabel = "DeepSeek";
              customParams = {
                defaultParamsEndpoint = "custom";
                paramDefinitions = [
                  {
                    key = "max_tokens";
                    type = "number";
                    component = "slider";
                    default = 48000;
                    range = {
                      min = 3000;
                      max = 384000;
                      step = 3000;
                    };
                  }
                  {
                    key = "maxContextTokens";
                    type = "number";
                    component = "slider";
                    default = 1048576;
                    range = {
                      min = 1024;
                      max = 1048576;
                      step = 1024;
                    };
                  }
                ];
              };
            }
            {
              name = "Moonshot";
              apiKey = "\${MOONSHOT_API_KEY}";
              baseURL = "https://api.moonshot.cn/v1";
              models = {
                default = [ "kimi-k2.6" ];
                fetch = true;
              };
              modelDisplayLabel = "Moonshot";
            }
            {
              name = "OpenRouter";
              apiKey = "\${OPENROUTER_KEY}";
              baseURL = "https://openrouter.ai/api/v1";
              models = {
                default = [ "deepseek/deepseek-v4-pro" "deepseek/deepseek-v4-flash" ];
                fetch = false;
              };
              dropParams = [ "stop" ];
              modelDisplayLabel = "OpenRouter";
            }
          ];
        };
      };
    };
  };
}
