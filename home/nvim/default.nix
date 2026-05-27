{ inputs, osConfig, ... }:

{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    nixpkgs.source = inputs.nixpkgs;
    _module.args = { inherit inputs osConfig; };
    imports = [
      { nixpkgs.config.allowUnfree = true; }
      ./option.nix
      ./keymap.nix
      ./theme.nix
      ./plugins
    ];
  };
}
