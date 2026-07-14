{ pkgs, inputs, osConfig, sources, ... }:

let
  nixpakPackages = import ./nixpak {
    inherit pkgs inputs osConfig;
  };
in
  nixpakPackages
  // {
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
