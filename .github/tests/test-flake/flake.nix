{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    terra.url = "path:../../../";
  };

  outputs = { nixpkgs, terra, ... }: {
    nixosConfigurations.ci-diff = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ ... }: {
          boot.initrd.availableKernelModules = [ "virtio" ];
          boot.kernelModules = [ ];
          boot.loader.grub.devices = [ "/dev/vda" ];
        })
        (import ../../../templates/hosts/host_name)
        terra.terraModules.default
        ({ config, lib, ... }: {
          config = {
            _module.args.inputs = lib.mkForce
              (terra.inputs // { nixpkgs = nixpkgs; });
            terra = {
              hostName = "ci-diff";
              userName = lib.mkForce "ci";
            };
          };
        })
      ];
    };
  };
}
