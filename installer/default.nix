{ inputs }:

let
  lib = inputs.nixpkgs.lib;

  targetSystem = lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      { nixpkgs.hostPlatform = "x86_64-linux"; }
      ./target.nix
    ];
  };
in
lib.nixosSystem {
  specialArgs = { inherit targetSystem; };
  modules = [
    { nixpkgs.hostPlatform = "x86_64-linux"; }
    ./live.nix
  ];
}
