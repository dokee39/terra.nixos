{ osConfig, inputs, ... }:

{
  imports = [ inputs.ags.homeManagerModules.default ];

  programs.ags = {
    enable = true;
    configDir = ./.;

    extraPackages = with inputs.ags.packages.${osConfig.terra.system}; [
      hyprland
      wireplumber
    ];
  };
}
