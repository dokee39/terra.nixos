{ config, pkgs, lib, inputs, ... }:

let
  cfg = config.terra.ai.mcp.duckduckgo;

  hostnamesRemove = [
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

  hostnamesLowPriority = [
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

  hostnamesHighPriority = [
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
    "(.*\\.)?wiki\\.archlinux\\.org$"
    "(.*\\.)?man\\.archlinux\\.org$"
    "(.*\\.)?aur\\.archlinux\\.org$"
    "(.*\\.)?bbs\\.archlinux\\.org$"
    "(.*\\.)?bugs\\.archlinux\\.org$"
    "(.*\\.)?wiki\\.gentoo\\.org$"
    "(.*\\.)?packages\\.gentoo\\.org$"
    "(.*\\.)?forums\\.gentoo\\.org$"
    "(.*\\.)?nixos\\.wiki$"
    "(.*\\.)?nixos\\.org$"
    "(.*\\.)?search\\.nixos\\.org$"
    "(.*\\.)?discourse\\.nixos\\.org$"
    "(.*\\.)?nginx\\.org$"
    "(.*\\.)?openwrt\\.org$"
    "(.*\\.)?freebsd\\.org$"
    "(.*\\.)?tldp\\.org$"
    # === Package registries and tools ===
    "(.*\\.)?npmjs\\.com$"
    "(.*\\.)?pypi\\.org$"
    "(.*\\.)?crates\\.io$"
    "(.*\\.)?hex\\.pm$"
    "(.*\\.)?hub\\.docker\\.com$"
    "(.*\\.)?pkg\\.go\\.dev$"
    "(.*\\.)?directory\\.fsf\\.org$"
    # === Code hosting & collaboration ===
    "(.*\\.)?codeberg\\.org$"
    "(.*\\.)?gitlab\\.com$"
    # === AI & ML ===
    "(.*\\.)?huggingface\\.co$"
    # === Tech communities & news ===
    "(.*\\.)?lobste\\.rs$"
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

  toPyList = lst: "[${lib.concatStringsSep ", " (map (s: "r\"${s}\"") lst)}]";

  filterUtilsModule = pkgs.writeText "filter_utils.py" ''
    import re
    from urllib.parse import urlsplit

    _REMOVE_HOSTNAMES = ${toPyList hostnamesRemove}
    _LOW_PRIORITY_HOSTNAMES = ${toPyList hostnamesLowPriority}
    _HIGH_PRIORITY_HOSTNAMES = ${toPyList hostnamesHighPriority}

    _COMPILED_REMOVE = [re.compile(p, re.IGNORECASE) for p in _REMOVE_HOSTNAMES]
    _COMPILED_LOW = [re.compile(p, re.IGNORECASE) for p in _LOW_PRIORITY_HOSTNAMES]
    _COMPILED_HIGH = [re.compile(p, re.IGNORECASE) for p in _HIGH_PRIORITY_HOSTNAMES]

    def _hostname_matches(netloc, patterns):
        for pat in patterns:
            if pat.search(netloc):
                return True
        return False

    def _filter_and_rank(results):
        filtered = []
        for r in results:
            netloc = urlsplit(r.link).netloc.lower()
            if _hostname_matches(netloc, _COMPILED_REMOVE):
                continue
            filtered.append(r)

        def bucket(r):
            netloc = urlsplit(r.link).netloc.lower()
            if _hostname_matches(netloc, _COMPILED_HIGH):
                return -1
            if _hostname_matches(netloc, _COMPILED_LOW):
                return 1
            return 0

        filtered.sort(key=lambda r: (bucket(r), r.position))

        for i, r in enumerate(filtered, start=1):
            r.position = i

        return filtered
  '';

  duckduckgo-mcp-pkg = pkgs.python3Packages.buildPythonApplication {
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

    postPatch = ''
      cp ${filterUtilsModule} src/duckduckgo_mcp_server/filter_utils.py

      substituteInPlace src/duckduckgo_mcp_server/server.py \
        --replace-fail \
          "from enum import Enum" \
          "from enum import Enum
from duckduckgo_mcp_server.filter_utils import _filter_and_rank"

      substituteInPlace src/duckduckgo_mcp_server/server.py \
        --replace-fail \
          'await ctx.info(f"Successfully found {len(results)} results")' \
          'results = _filter_and_rank(results)
            await ctx.info(f"Successfully found {len(results)} results (after filtering)")'
    '';

    doCheck = false;
  };
in {
  options.terra.ai.mcp.duckduckgo = {
    enable = lib.mkEnableOption "DuckDuckGo MCP Server (stdio)";
  };

  config = lib.mkIf cfg.enable {
    terra.ai.mcp.servers.duckduckgo = {
      type = "stdio";
      command = "${duckduckgo-mcp-pkg}/bin/duckduckgo-mcp-server";
      args = [ "--fetch-backend" "auto" ];
      env = {
        DDG_SAFE_SEARCH = "STRICT";
        DDG_REGION = "us-en";
      };
    };
  };
}
