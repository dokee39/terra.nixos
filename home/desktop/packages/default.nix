{ pkgs, inputs, osConfig, ... }:

let
  nixpakPackages = import ./nixpak {
    inherit pkgs inputs osConfig;
  };
in
  nixpakPackages
  // {
    mikan = pkgs.callPackage ./mikan.nix {
      src = inputs.mikan;
    };

    "nautilus-image-converter" = pkgs.callPackage ./nautilus-image-converter.nix {
      src = inputs."nautilus-image-converter";
    };
  }
