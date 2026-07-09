{
  inputs = {
    terra.url = "github:dokee39/terra.nixos";
    nixpkgs.follows = "terra/nixpkgs";
  };

  outputs = { nixpkgs, terra, ... }: let
    lib = nixpkgs.lib;
    hosts = builtins.attrNames (builtins.readDir ./hosts);
    mkHost = hostName: lib.nixosSystem {
      modules = [
        ./hosts/${hostName}
        terra.terraModules.default
        { terra.hostName = hostName; }
      ];
    };
  in {
    nixosConfigurations = lib.genAttrs hosts mkHost;
  };
}
