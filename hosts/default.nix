{ inputs, sources }:

hostName:
inputs.nixpkgs.lib.nixosSystem {
  modules = [
    ./${hostName}
    { terra.hostName = hostName; }
    ../system
    inputs.agenix.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    (
      { config, ... }:
      let
        pkgs-stable = import inputs.nixpkgs-stable {
          inherit (config.nixpkgs.hostPlatform) system;
          config.allowUnfree = true;
        };
      in
      {
        _module.args = {
          inherit inputs sources pkgs-stable;
          inherit (inputs) self;
        };
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit inputs sources pkgs-stable;
            inherit (inputs) self;
          };
          sharedModules = [
            inputs.agenix.homeManagerModules.default
          ];
          users.${config.terra.userName} = import ../home;
        };
      }
    )
  ];
}
