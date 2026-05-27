{ pkgs, customPackages, ... }:

let
  cExtensionPackages = with pkgs; [
    nautilus
    nautilus-python
    file-roller
    customPackages."nautilus-image-converter"
  ];

  pythonExtensionPackages = with pkgs; [
    turtle
    code-nautilus
    nautilus-open-any-terminal
  ];

  nautilusExtensionsEnv = pkgs.buildEnv {
    name = "nautilus-extensions-env";
    paths = cExtensionPackages;
    pathsToLink = [ "/lib/nautilus/extensions-4" ];
  };

  nautilusPythonExtensionsEnv = pkgs.buildEnv {
    name = "nautilus-python-extensions-env";
    paths = pythonExtensionPackages;
    pathsToLink = [ "/share/nautilus-python/extensions" ];
  };
in
{
  home.packages = with pkgs; [
    nautilus
    turtle
    code-nautilus
    nautilus-open-any-terminal
    sushi
    file-roller
  ] ++ [
    customPackages."nautilus-image-converter"
  ];

  home.sessionVariables = {
    NAUTILUS_4_EXTENSION_DIR = "${nautilusExtensionsEnv}/lib/nautilus/extensions-4";
  };

  xdg.dataFile."nautilus-python/extensions" = {
    source = "${nautilusPythonExtensionsEnv}/share/nautilus-python/extensions";
    recursive = true;
  };

  dconf.settings = {
    "com/github/stunkymonkey/nautilus-open-any-terminal" = {
      terminal = "kitty";
      new-tab = true;
    };
  };
}
