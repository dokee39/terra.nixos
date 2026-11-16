{ pkgs, inputs, sources, ... }:

{
  clice = pkgs.callPackage ./clice.nix {
    source = sources.clice;
  };

  mikan = pkgs.callPackage ./mikan.nix {
    source = sources.mikan;
  };

  aegisub = pkgs.callPackage ./aegisub.nix {
    source = sources.aegisub;
  };

  "nautilus-image-converter" = pkgs.callPackage ./nautilus-image-converter.nix {
    src = inputs."nautilus-image-converter";
  };
}
