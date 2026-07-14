{ pkgs, lib, sources, ... }:

let
  mapleMonoFont = pkgs.maple-mono.NF-CN-unhinted;

  pi-web = pkgs.buildNpmPackage {
    pname = "pi-web";
    version = sources.pi-web.version;
    src = pkgs.fetchFromGitHub {
      owner = sources.pi-web.owner;
      repo  = sources.pi-web.repo;
      rev   = sources.pi-web.rev;
      hash  = sources.pi-web.hash;
    };

    npmDepsFetcherVersion = 2;
    makeCacheWritable = true;
    npmFlags = [ "--legacy-peer-deps" ];
    npmDepsHash = "sha256-MffdpqEw2PGHYyrWvLaFrWlhtTS91P7C5HBC599k2no=";

    postPatch = ''
      mkdir -p app/fonts
      for f in Regular Medium SemiBold Bold; do
        cp "${mapleMonoFont}/share/fonts/truetype/MapleMono-NF-CN-$f.ttf" app/fonts/MapleMono-NF-CN-$f.ttf
      done
      substituteInPlace app/layout.tsx \
        --replace 'import { Noto_Sans_Mono } from "next/font/google";' 'import localFont from "next/font/local";' \
        --replace 'const notoSansMono = Noto_Sans_Mono({' 'const notoSansMono = localFont({' \
        --replace '  subsets: ["latin", "cyrillic"],' '  src: [
    { path: "./fonts/MapleMono-NF-CN-Regular.ttf", weight: "400", style: "normal" },
    { path: "./fonts/MapleMono-NF-CN-Medium.ttf", weight: "500", style: "normal" },
    { path: "./fonts/MapleMono-NF-CN-SemiBold.ttf", weight: "600", style: "normal" },
    { path: "./fonts/MapleMono-NF-CN-Bold.ttf", weight: "700", style: "normal" },
  ],'
    '';

    meta = {
      description = "Web UI for the pi coding agent";
      homepage = "https://github.com/agegr/pi-web";
      license = lib.licenses.mit;
    };
  };

  pi-wrapper = pkgs.writeShellScriptBin "pi" ''
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      exec ${lib.getExe pkgs.pi-coding-agent} --extension npm:@ayulab/pi-rewind  "$@"
    else
      exec ${lib.getExe pkgs.pi-coding-agent} "$@"
    fi
  '';

  pichat = pkgs.writeShellScriptBin "pichat" ''
    args=(); here=
    for a; do [ "$a" = "--here" ] && here=1 || args+=("$a"); done
    [ "$here" ] || cd /tmp
    pi --append-system-prompt ${./APPEND_SYSTEM.md} \
       --append-system-prompt ${./chat-instruction.md} \
       "''${args[@]}"
    [ "$here" ] || cd - > /dev/null
  '';
in
{
  imports = [ ./web-tool ];

  programs.pi-coding-agent = {
    enable = true;
    package = pi-wrapper;
    extraPackages = [ pkgs.nodejs ];

    settings = {
      quietStartup = true;
      collapseChangelog = true;

      enableInstallTelemetry = false;
      enableAnalytics = false;

      defaultProvider = "deepseek";
      defaultModel = "deepseek-v4-flash";
      defaultThinkingLevel = "high";

      autocompleteMaxVisible = 10;

      packages = [
        "npm:@firstpick/pi-themes-bundle"
        # "npm:@ayulab/pi-rewind"
        "npm:@aliou/pi-guardrails"
        "npm:pi-rtk-optimizer"
        "npm:pi-cache-optimizer"
        "npm:@juicesharp/rpiv-btw"
      ];

      theme = "rose-pine";
    };
  };

  home.packages = [ pkgs.rtk pichat pi-web ];

  home.sessionVariables = {
    PI_SKIP_VERSION_CHECK  = "1";
  };

  home.file.".pi/agent/APPEND_SYSTEM.md".source = ./APPEND_SYSTEM.md;
  home.file.".pi/agent/models.json".source = ./models.json;
  home.file.".pi/agent/extensions/web-tools.ts".source = ./extensions/web-tools.ts;
  home.file.".pi/agent/skills" = {
    source = ./skills;
    recursive = true;
  };
  home.file.".pi/agent/prompts" = {
    source = ./prompts;
    recursive = true;
  };

  systemd.user.services.pi-web = {
    Unit = {
      Description = "Web UI for pi coding agent";
      After = [ "network.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pi-web}/bin/pi-web --hostname 127.0.0.1";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
