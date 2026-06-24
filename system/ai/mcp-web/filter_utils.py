import re
from urllib.parse import urlsplit

_REMOVE_HOSTNAMES = [
    # === Chinese content farms ===
    r"(.*\.)?csdn\.net$",
    r"(.*\.)?csdn\.com$",
    r"(.*\.)?php\.cn$",
    r"(.*\.)?runoob\.com$",
    r"(.*\.)?jiaocheng\.com$",
    r"(.*\.)?xuexila\.com$",
    r"(.*\.)?yisu\.com$",
    r"(.*\.)?yiibai\.com$",
    r"(.*\.)?biancheng\.net$",
    r"(.*\.)?jb51\.net$",
    r"(.*\.)?it1352\.com$",
    r"(.*\.)?codeleading\.com$",
    r"(.*\.)?kknews\.cc$",
    # === Low-quality Chinese developer communities / cloud vendors ===
    r"(.*\.)?aliyun\.com$",
    r"(.*\.)?cloud\.tencent\.com$",
    r"(.*\.)?bbs\.huaweicloud\.com$",
    r"(.*\.)?segmentfault\.com$",
    r"(.*\.)?juejin\.cn$",
    r"(.*\.)?jianshu\.com$",
    # === Chinese junk encyclopedias / Q&A ===
    r"(.*\.)?baike\.baidu\.com$",
    r"(.*\.)?zhidao\.baidu\.com$",
    r"(.*\.)?wenku\.baidu\.com$",
    r"(.*\.)?jingyan\.baidu\.com$",
    # === English SEO farms / low-quality tutorial sites ===
    r"(.*\.)?w3schools\.com$",
    r"(.*\.)?tutorialspoint\.com$",
    r"(.*\.)?geeksforgeeks\.org$",
    r"(.*\.)?programiz\.com$",
    r"(.*\.)?javatpoint\.com$",
    r"(.*\.)?w3resource\.com$",
    r"(.*\.)?studytonight\.com$",
    r"(.*\.)?educba\.com$",
    r"(.*\.)?simplilearn\.com$",
    r"(.*\.)?edureka\.co$",
    # === Visual/image clutter ===
    r"(.*\.)?pinterest\.com$",
    # === Outdated or unhelpful official forums ===
    r"(.*\.)?answers\.microsoft\.com$",
    # === Dictionary / reference sites ===
    r"(.*\.)?merriam-webster\.com$",
    r"(.*\.)?dictionary\.cambridge\.org$",
    r"(.*\.)?collinsdictionary\.com$",
    r"(.*\.)?oxfordlearnersdictionaries\.com$",
    r"(.*\.)?thefreedictionary\.com$",
    r"(.*\.)?dictionary\.com$",
    r"(.*\.)?thesaurus\.com$",
    r"(.*\.)?vocabulary\.com$",
    r"(.*\.)?etymonline\.com$",
    r"(.*\.)?en\.wiktionary\.org$",
    r"(.*\.)?wordreference\.com$",
    r"(.*\.)?macmillandictionary\.com$",
    r"(.*\.)?ldoceonline\.com$",
    r"(.*\.)?britannica\.com$",
    r"(.*\.)?yourdictionary\.com$",
    r"(.*\.)?lexico\.com$",
    r"(.*\.)?iciba\.com$",
    r"(.*\.)?dict\.cn$",
    r"(.*\.)?youdao\.com$",
    r"(.*\.)?fanyi\.baidu\.com$",
    r"(.*\.)?glosbe\.com$",
    r"(.*\.)?linguee\.com$",
    r"(.*\.)?deepl\.com$",
    r"(.*\.)?bab\.la$",
    r"(.*\.)?context\.reverso\.net$",
]

_LOW_PRIORITY_HOSTNAMES = [
    # === Knowledge Q&A / blogs (occasionally useful but noisy) ===
    r"(.*\.)?zhihu\.com$",
    r"(.*\.)?quora\.com$",
    r"(.*\.)?medium\.com$",
    r"(.*\.)?dev\.to$",
    r"(.*\.)?hashnode\.com$",
    r"(.*\.)?dzone\.com$",
    r"(.*\.)?slant\.co$",
    # === Tutorial sites still having some value (lowered to be observed) ===
    r"(.*\.)?baeldung\.com$",
    # === Dictionary / reference sites ===
    r"(.*\.)?en\.wiktionary\.org$",
    r"(.*\.)?etymonline\.com$",
    r"(.*\.)?britannica\.com$",
]

_HIGH_PRIORITY_HOSTNAMES = [
    # === Knowledge cornerstones ===
    r"(.*\.)?wikipedia\.org$",
    r"(.*\.)?github\.com$",
    r"(.*\.)?stackoverflow\.com$",
    r"(.*\.)?stackexchange\.com$",
    r"(.*\.)?askubuntu\.com$",
    r"(.*\.)?serverfault\.com$",
    r"(.*\.)?superuser\.com$",
    # === Official programming language documentation ===
    r"(.*\.)?docs\.python\.org$",
    r"(.*\.)?nodejs\.org$",
    r"(.*\.)?golang\.org$",
    r"(.*\.)?doc\.rust-lang\.org$",
    r"(.*\.)?docs\.oracle\.com$",
    r"(.*\.)?kotlinlang\.org$",
    r"(.*\.)?swift\.org$",
    r"(.*\.)?ruby-doc\.org$",
    r"(.*\.)?elixir-lang\.org$",
    r"(.*\.)?hexdocs\.pm$",
    # === Frontend & Web standards ===
    r"(.*\.)?developer\.mozilla\.org$",
    r"(.*\.)?reactjs\.org$",
    r"(.*\.)?react\.dev$",
    r"(.*\.)?vuejs\.org$",
    r"(.*\.)?angular\.io$",
    r"(.*\.)?w3\.org$",
    r"(.*\.)?caniuse\.com$",
    r"(.*\.)?web\.dev$",
    # === Databases ===
    r"(.*\.)?postgresql\.org$",
    r"(.*\.)?dev\.mysql\.com$",
    r"(.*\.)?sqlite\.org$",
    r"(.*\.)?mongodb\.com/docs$",
    # === DevOps / Cloud official sites ===
    r"(.*\.)?kubernetes\.io$",
    r"(.*\.)?docker\.com$",
    r"(.*\.)?docs\.docker\.com$",
    r"(.*\.)?helm\.sh$",
    r"(.*\.)?terraform\.io$",
    r"(.*\.)?docs\.ansible\.com$",
    # === Linux / BSD / System ===
    r"(.*\.)?kernel\.org$",
    r"(.*\.)?wiki\.archlinux\.org$",
    r"(.*\.)?man\.archlinux\.org$",
    r"(.*\.)?aur\.archlinux\.org$",
    r"(.*\.)?bbs\.archlinux\.org$",
    r"(.*\.)?bugs\.archlinux\.org$",
    r"(.*\.)?wiki\.gentoo\.org$",
    r"(.*\.)?packages\.gentoo\.org$",
    r"(.*\.)?forums\.gentoo\.org$",
    r"(.*\.)?nixos\.wiki$",
    r"(.*\.)?nixos\.org$",
    r"(.*\.)?search\.nixos\.org$",
    r"(.*\.)?discourse\.nixos\.org$",
    r"(.*\.)?nginx\.org$",
    r"(.*\.)?openwrt\.org$",
    r"(.*\.)?freebsd\.org$",
    r"(.*\.)?tldp\.org$",
    # === Package registries and tools ===
    r"(.*\.)?npmjs\.com$",
    r"(.*\.)?pypi\.org$",
    r"(.*\.)?crates\.io$",
    r"(.*\.)?hex\.pm$",
    r"(.*\.)?hub\.docker\.com$",
    r"(.*\.)?pkg\.go\.dev$",
    r"(.*\.)?directory\.fsf\.org$",
    # === Code hosting & collaboration ===
    r"(.*\.)?codeberg\.org$",
    r"(.*\.)?gitlab\.com$",
    # === AI & ML ===
    r"(.*\.)?huggingface\.co$",
    # === Tech communities & news ===
    r"(.*\.)?lobste\.rs$",
    r"(.*\.)?news\.ycombinator\.com$",
    r"(.*\.)?hackerne\.ws$",
    # === Documentation & manual pages ===
    r"(.*\.)?mankier\.com$",
    r"(.*\.)?devdocs\.io$",
    # === Academic & specifications ===
    r"(.*\.)?arxiv\.org$",
    r"(.*\.)?ieeexplore\.ieee\.org$",
    r"(.*\.)?crossref\.org$",
    r"(.*\.)?scholar\.google\.com$",
    r"(.*\.)?pubmed\.ncbi\.nlm\.nih\.gov$",
    r"(.*\.)?semanticscholar\.org$",
    r"(.*\.)?openaire\.eu$",
    r"(.*\.)?pdbe\.org$",
    r"(.*\.)?git-scm\.com$",
    r"(.*\.)?specifications\.freedesktop\.org$",
    r"(.*\.)?letsencrypt\.org$",
]

_COMPILED_REMOVE = [re.compile(p, re.IGNORECASE) for p in _REMOVE_HOSTNAMES]
_COMPILED_LOW = [re.compile(p, re.IGNORECASE) for p in _LOW_PRIORITY_HOSTNAMES]
_COMPILED_HIGH = [re.compile(p, re.IGNORECASE) for p in _HIGH_PRIORITY_HOSTNAMES]


def _matches(netloc: str, patterns: list) -> bool:
    return any(p.search(netloc) for p in patterns)


def filter_and_rank(results: list) -> list:
    """Remove unwanted hostnames and sort by priority bucket then original position."""
    filtered = [
        r for r in results
        if not _matches(urlsplit(r.link).netloc.lower(), _COMPILED_REMOVE)
    ]

    def bucket(r) -> int:
        netloc = urlsplit(r.link).netloc.lower()
        if _matches(netloc, _COMPILED_HIGH):
            return -1
        if _matches(netloc, _COMPILED_LOW):
            return 1
        return 0

    filtered.sort(key=lambda r: (bucket(r), r.position))

    for i, r in enumerate(filtered, start=1):
        r.position = i

    return filtered
