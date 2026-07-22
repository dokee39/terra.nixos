{ config, pkgs, lib, inputs, sources, ... }:

{
  config = lib.mkIf config.terra.desktop.enable {
    fonts = {
      fontDir.enable = true;

      enableDefaultPackages = true;
      fontconfig.allowBitmaps = false;
      fontconfig.useEmbeddedBitmaps = true;

      packages = let
        lxgwBrightGB = pkgs.stdenvNoCC.mkDerivation {
          pname = "lxgw-bright-gb";
          version = "unstable-${inputs.lxgw-bright.lastModifiedDate}";
          src = inputs.lxgw-bright;

          dontConfigure = true;
          dontBuild = true;

          installPhase = ''
          runHook preInstall

          install -dm755 "$out/share/fonts/truetype"

          find . -type f -iname 'LXGWBright*.ttf' \
          -exec install -m644 -t "$out/share/fonts/truetype" {} +

          runHook postInstall
          '';
        };
        mapleBrightFont = source: pkgs.fetchurl {
          inherit (source) url hash;
        };
        mapleBright = pkgs.stdenvNoCC.mkDerivation {
          pname = "maple-bright";
          version = sources.maple-bright-regular.version;
          dontUnpack = true;

          installPhase = ''
            install -dm755 "$out/share/fonts/truetype"
            install -m644 ${mapleBrightFont sources.maple-bright-regular} \
              "$out/share/fonts/truetype/MapleBright-Regular.ttf"
            install -m644 ${mapleBrightFont sources.maple-bright-medium} \
              "$out/share/fonts/truetype/MapleBright-Medium.ttf"
            install -m644 ${mapleBrightFont sources.maple-bright-italic} \
              "$out/share/fonts/truetype/MapleBright-Italic.ttf"
            install -m644 ${mapleBrightFont sources.maple-bright-medium-italic} \
              "$out/share/fonts/truetype/MapleBright-MediumItalic.ttf"
          '';
        };
      in with pkgs; [
        noto-fonts-lgc-plus
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji

        lxgw-wenkai
        lxgw-neoxihei
        lxgwBrightGB
        mapleBright

        monaspace
        maple-mono.NF-CN-unhinted
        nerd-fonts.symbols-only

        inter
        libertinus
        ocr-a
      ];
    };
  };
}
