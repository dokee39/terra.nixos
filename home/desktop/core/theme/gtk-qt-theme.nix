{ inputs, pkgs, ... }:

{
  gtk = {
    enable = true;

    theme = {
      package = pkgs.orchis-theme;
      name = "Orchis-Dark";
    };

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };

    gtk4 = {
      theme = {
        package = pkgs.orchis-theme;
        name = "Orchis-Dark";
      };
    };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "Orchis-Dark";
    icon-theme = "Papirus-Dark";
  };

  qt = {
    enable = true;
    style.name = "kvantum";
    platformTheme.name = "kde";
  };

  home.packages = with pkgs.kdePackages; [
    frameworkintegration
    breeze-icons
  ];

  xdg.dataFile."color-schemes/OrchisDark.colors".source =
    "${inputs.orchis-kde}/color-schemes/OrchisDark.colors";

  xdg.configFile = {
    "Kvantum/OrchisDark/OrchisDark.kvconfig".source =
      "${inputs.orchis-kde}/Kvantum/Orchis/OrchisDark.kvconfig";
    "Kvantum/OrchisDark/OrchisDark.svg".source =
      "${inputs.orchis-kde}/Kvantum/Orchis/OrchisDark.svg";

    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=OrchisDark
    '';

    "kdeglobals".text = ''
      [General]
      ColorScheme=OrchisDark

      [Icons]
      Theme=Papirus-Dark
    '';
  };
}
