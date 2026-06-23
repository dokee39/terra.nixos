{ config, lib, ... }:

let 
  cfg = config.terra.ai.searxng;
in {
  options.terra.ai.searxng = {
    enable = lib.mkEnableOption "SearXNG service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8888;
    };
    env_secretFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a secret file containing the searx .env file.
        > $ openssl rand -hex 32
        ```
          SEARXNG_SECRET=xxx
        ```
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.searx-env.file = cfg.env_secretFile;

    services.searx = {
      enable = true;
      redisCreateLocally = true;
      environmentFile = config.age.secrets.searx-env.path;

      settings = {
        use_default_settings = true;

        search = {
          formats = [ "html" "json" ];
        };

        server = {
          port = cfg.port;
          method = "GET";
          limiter = false;
          secret_key = "\${SEARXNG_SECRET}";
        };

        outgoing.proxies."all://" = [ config.networking.proxy.default ];

        engines = [
          { name = "bing"; disabled = true; }
          { name = "bing news"; disabled = true; }
          { name = "bing images"; disabled = true; }
          { name = "bing videos"; disabled = true; }
          { name = "qwant"; disabled = true; }
          { name = "qwant news"; disabled = true; }
          { name = "qwant images"; disabled = true; }
          { name = "qwant videos"; disabled = true; }
          { name = "brave"; disabled = true; }
          { name = "brave.news"; disabled = true; }
          { name = "brave.images"; disabled = true; }
          { name = "brave.videos"; disabled = true; }
          { name = "karmasearch"; disabled = true; }
          { name = "karmasearch news"; disabled = true; }
          { name = "karmasearch images"; disabled = true; }
          { name = "karmasearch videos"; disabled = true; }
          { name = "ahmia"; disabled = true; }
          { name = "torch"; disabled = true; }

          { name = "google"; weight = 2.0; }
          { name = "startpage"; weight = 2.0; }
          { name = "duckduckgo"; weight = 2.0; }
          { name = "wikipedia"; weight = 3.0; }
          { name = "wikidata"; weight = 3.0; }
          { name = "library of congress"; disabled = false; }

          { name = "crates.io"; disabled = false; weight = 2.0; }
          { name = "hex"; disabled = false; }
          { name = "npm"; disabled = false; }
          { name = "pkg.go.dev"; disabled = false; }
          { name = "askubuntu"; weight = 2.0; }
          { name = "stackoverflow"; weight = 3.0; }
          { name = "codeberg"; weight = 2.0; }
          { name = "github"; weight = 2.0; }
          { name = "huggingface"; disabled = false; }
          { name = "arch linux wiki"; weight = 3.0; }
          { name = "gentoo"; weight = 2.5; }
          { name = "free software directory"; disabled = false; weight = 2.5; }
          { name = "nixos wiki"; disabled = false; weight = 3.0; }
          { name = "lobste.rs"; disabled = false; }
          { name = "hackernews"; disabled = false; }
          { name = "mankier"; disabled = false; }
          { name = "mdn"; weight = 2.0; }

          { name = "arxiv"; weight = 2.5; }
          { name = "google scholar"; weight = 2.5; }
          { name = "semantic scholar"; weight = 2.0; }
          { name = "crossref"; disabled = false; }
          { name = "core.ac.uk"; disabled = false; }
        ];

        hostnames = {
          remove = [
            # === Chinese content farms ===
            "(.*\\.)?csdn\\.net$"
            "(.*\\.)?csdn\\.com$"
            "(.*\\.)?php\\.cn$"
            "(.*\\.)?runoob\\.com$"
            "(.*\\.)?jiaocheng\\.com$"
            "(.*\\.)?xuexila\\.com$"
            "(.*\\.)?yisu\\.com$"
            "(.*\\.)?yiibai\\.com$"
            "(.*\\.)?biancheng\\.net$"
            "(.*\\.)?jb51\\.net$"
            "(.*\\.)?it1352\\.com$"
            "(.*\\.)?codeleading\\.com$"
            "(.*\\.)?kknews\\.cc$"

            # === Low-quality Chinese developer communities / cloud vendors ===
            "(.*\\.)?aliyun\\.com$"
            "(.*\\.)?cloud\\.tencent\\.com$"
            "(.*\\.)?bbs\\.huaweicloud\\.com$"
            "(.*\\.)?segmentfault\\.com$"
            "(.*\\.)?juejin\\.cn$"
            "(.*\\.)?jianshu\\.com$"

            # === Chinese junk encyclopedias / Q&A ===
            "(.*\\.)?baike\\.baidu\\.com$"
            "(.*\\.)?zhidao\\.baidu\\.com$"
            "(.*\\.)?wenku\\.baidu\\.com$"
            "(.*\\.)?jingyan\\.baidu\\.com$"

            # === English SEO farms / low-quality tutorial sites ===
            "(.*\\.)?w3schools\\.com$"
            "(.*\\.)?tutorialspoint\\.com$"
            "(.*\\.)?geeksforgeeks\\.org$"
            "(.*\\.)?programiz\\.com$"
            "(.*\\.)?javatpoint\\.com$"
            "(.*\\.)?w3resource\\.com$"
            "(.*\\.)?studytonight\\.com$"
            "(.*\\.)?educba\\.com$"
            "(.*\\.)?simplilearn\\.com$"
            "(.*\\.)?edureka\\.co$"

            # === Visual/image clutter ===
            "(.*\\.)?pinterest\\.com$"

            # === Outdated or unhelpful official forums ===
            "(.*\\.)?answers\\.microsoft\\.com$"

            # === Dictionary / reference sites ===
            "(.*\\.)?merriam-webster\\.com$"
            "(.*\\.)?dictionary\\.cambridge\\.org$"
            "(.*\\.)?collinsdictionary\\.com$"
            "(.*\\.)?oxfordlearnersdictionaries\\.com$"
            "(.*\\.)?thefreedictionary\\.com$"
            "(.*\\.)?dictionary\\.com$"
            "(.*\\.)?thesaurus\\.com$"
            "(.*\\.)?vocabulary\\.com$"
            "(.*\\.)?etymonline\\.com$"
            "(.*\\.)?en\\.wiktionary\\.org$"
            "(.*\\.)?wordreference\\.com$"
            "(.*\\.)?macmillandictionary\\.com$"
            "(.*\\.)?ldoceonline\\.com$"
            "(.*\\.)?britannica\\.com$"
            "(.*\\.)?yourdictionary\\.com$"
            "(.*\\.)?lexico\\.com$"
            "(.*\\.)?iciba\\.com$"
            "(.*\\.)?dict\\.cn$"
            "(.*\\.)?youdao\\.com$"
            "(.*\\.)?fanyi\\.baidu\\.com$"
            "(.*\\.)?glosbe\\.com$"
            "(.*\\.)?linguee\\.com$"
            "(.*\\.)?deepl\\.com$"
            "(.*\\.)?bab\\.la$"
            "(.*\\.)?context\\.reverso\\.net$"
          ];

          low_priority = [
            # === Knowledge Q&A / blogs (occasionally useful but noisy) ===
            "(.*\\.)?zhihu\\.com$"
            "(.*\\.)?quora\\.com$"
            "(.*\\.)?medium\\.com$"
            "(.*\\.)?dev\\.to$"
            "(.*\\.)?hashnode\\.com$"
            "(.*\\.)?dzone\\.com$"
            "(.*\\.)?slant\\.co$"

            # === Tutorial sites still having some value (lowered to be observed) ===
            "(.*\\.)?baeldung\\.com$"

            # === Dictionary / reference sites ===
            "(.*\\.)?en\\.wiktionary\\.org$"
            "(.*\\.)?etymonline\\.com$"
            "(.*\\.)?britannica\\.com$"
          ];

          high_priority = [
            # === Knowledge cornerstones ===
            "(.*\\.)?wikipedia\\.org$"
            "(.*\\.)?github\\.com$"
            "(.*\\.)?stackoverflow\\.com$"
            "(.*\\.)?stackexchange\\.com$"
            "(.*\\.)?askubuntu\\.com$"
            "(.*\\.)?serverfault\\.com$"
            "(.*\\.)?superuser\\.com$"

            # === Official programming language documentation ===
            "(.*\\.)?docs\\.python\\.org$"
            "(.*\\.)?nodejs\\.org$"
            "(.*\\.)?golang\\.org$"
            "(.*\\.)?doc\\.rust-lang\\.org$"
            "(.*\\.)?docs\\.oracle\\.com$"
            "(.*\\.)?kotlinlang\\.org$"
            "(.*\\.)?swift\\.org$"
            "(.*\\.)?ruby-doc\\.org$"
            "(.*\\.)?elixir-lang\\.org$"
            "(.*\\.)?hexdocs\\.pm$"

            # === Frontend & Web standards ===
            "(.*\\.)?developer\\.mozilla\\.org$"
            "(.*\\.)?reactjs\\.org$"
            "(.*\\.)?react\\.dev$"
            "(.*\\.)?vuejs\\.org$"
            "(.*\\.)?angular\\.io$"
            "(.*\\.)?w3\\.org$"
            "(.*\\.)?caniuse\\.com$"
            "(.*\\.)?web\\.dev$"

            # === Databases ===
            "(.*\\.)?postgresql\\.org$"
            "(.*\\.)?dev\\.mysql\\.com$"
            "(.*\\.)?sqlite\\.org$"
            "(.*\\.)?mongodb\\.com/docs$"

            # === DevOps / Cloud official sites ===
            "(.*\\.)?kubernetes\\.io$"
            "(.*\\.)?docker\\.com$"
            "(.*\\.)?docs\\.docker\\.com$"
            "(.*\\.)?helm\\.sh$"
            "(.*\\.)?terraform\\.io$"
            "(.*\\.)?docs\\.ansible\\.com$"

            # === Linux / BSD / System ===
            "(.*\\.)?kernel\\.org$"
            # Arch Linux (wiki, AUR, forum, bug tracker)
            "(.*\\.)?wiki\\.archlinux\\.org$"
            "(.*\\.)?man\\.archlinux\\.org$"
            "(.*\\.)?aur\\.archlinux\\.org$"
            "(.*\\.)?bbs\\.archlinux\\.org$"
            "(.*\\.)?bugs\\.archlinux\\.org$"
            # Gentoo (wiki, packages, forum)
            "(.*\\.)?wiki\\.gentoo\\.org$"
            "(.*\\.)?packages\\.gentoo\\.org$"
            "(.*\\.)?forums\\.gentoo\\.org$"
            # NixOS & Nix (wiki, packages, options, community)
            "(.*\\.)?nixos\\.wiki$"
            "(.*\\.)?nixos\\.org$"
            "(.*\\.)?search\\.nixos\\.org$"
            "(.*\\.)?discourse\\.nixos\\.org$"
            # Other Linux/BSD
            "(.*\\.)?nginx\\.org$"
            "(.*\\.)?openwrt\\.org$"
            "(.*\\.)?freebsd\\.org$"
            "(.*\\.)?tldp\\.org$"

            # === Package registries and tools ===
            "(.*\\.)?npmjs\\.com$"
            "(.*\\.)?pypi\\.org$"
            "(.*\\.)?crates\\.io$"
            "(.*\\.)?hex\\.pm$"
            # Additional registries from your list
            "(.*\\.)?hub\\.docker\\.com$"
            "(.*\\.)?pkg\\.go\\.dev$"
            # Free Software Directory
            "(.*\\.)?directory\\.fsf\\.org$"

            # === Code hosting & collaboration ===
            "(.*\\.)?codeberg\\.org$"
            "(.*\\.)?gitlab\\.com$"
            # AI & ML
            "(.*\\.)?huggingface\\.co$"

            # === Tech communities & news ===
            "(.*\\.)?lobste\\.rs$"
            # Hacker News (main domain and legacy alias)
            "(.*\\.)?news\\.ycombinator\\.com$"
            "(.*\\.)?hackerne\\.ws$"

            # === Documentation & manual pages ===
            "(.*\\.)?mankier\\.com$"
            "(.*\\.)?devdocs\\.io$"

            # === Academic & specifications ===
            "(.*\\.)?arxiv\\.org$"
            "(.*\\.)?ieeexplore\\.ieee\\.org$"
            "(.*\\.)?crossref\\.org$"
            "(.*\\.)?scholar\\.google\\.com$"
            "(.*\\.)?pubmed\\.ncbi\\.nlm\\.nih\\.gov$"
            "(.*\\.)?semanticscholar\\.org$"
            "(.*\\.)?openaire\\.eu$"
            "(.*\\.)?pdbe\\.org$"
            "(.*\\.)?git-scm\\.com$"
            "(.*\\.)?specifications\\.freedesktop\\.org$"
            "(.*\\.)?letsencrypt\\.org$"
          ];
        };
      };
    };
  };
}
