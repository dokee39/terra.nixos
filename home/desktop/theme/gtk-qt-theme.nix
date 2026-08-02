{ inputs, pkgs, ... }:

let
  colloid-gtk-theme = pkgs.colloid-gtk-theme.override {
    tweaks = [ "normal" ];
  };
in {
  gtk = {
    enable = true;
    colorScheme = "dark";

    theme = {
      package = colloid-gtk-theme;
      name = "Colloid-Dark";
    };

    iconTheme = {
      package = pkgs.colloid-icon-theme;
      name = "Colloid-Dark";
    };

    gtk4.theme = {
      package = colloid-gtk-theme;
      name = "Colloid-Dark";
    };
  };

  qt = {
    enable = true;
    style.name = "kvantum";
    platformTheme.name = "kde";

    kvantum = {
      enable = true;
      settings.General.theme = "ColloidDark";
    };
  };

  home.packages = with pkgs.kdePackages; [
    frameworkintegration
    breeze-icons
  ];

  xdg.dataFile."color-schemes/ColloidDark.colors".source =
    "${inputs.colloid-kde}/color-schemes/ColloidDark.colors";

  xdg.configFile = {
    "Kvantum/ColloidDark/ColloidDark.kvconfig".source =
      "${inputs.colloid-kde}/Kvantum/Colloid/ColloidDark.kvconfig";
    "Kvantum/ColloidDark/ColloidDark.svg".source =
      "${inputs.colloid-kde}/Kvantum/Colloid/ColloidDark.svg";

    "kdeglobals".text = ''
      [General]
      ColorScheme=ColloidDark

      [Icons]
      Theme=Colloid-Dark
    '';
  };
}
