{ config, pkgs, lib, inputs, ... }:

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
          version = "main";
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
      in with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif

        inter
        libertinus

        lxgw-wenkai
        lxgw-neoxihei

        maple-mono.NF-CN-unhinted

        nerd-fonts.symbols-only

        lxgwBrightGB

        ocr-a
      ];
    };
  };
}
