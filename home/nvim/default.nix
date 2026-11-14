{ inputs, osConfig, ... }:

{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    nixpkgs.useGlobalPackages = true;
    _module.args = { inherit inputs osConfig; };
    imports = [
      ./option.nix
      ./keymap.nix
      ./theme.nix
      ./plugins
    ];
  };
}
