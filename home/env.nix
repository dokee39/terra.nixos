{ lib, osConfig, ... }:

{
  home.file.".local/bin" = {
    source = ./scripts;
    recursive = true;
  };

  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";

    PAGER = "less";
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "kitty";

    RANGER_LOAD_DEFAULT_RC = "FALSE";

    SCONSFLAGS = "-j8";
    MAKEFLAGS = "-j";
  } // lib.optionalAttrs (osConfig.terra.desktop.enable && osConfig.terra._internal.gpu.nvidiaEnabled) {
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
  } // lib.optionalAttrs osConfig.terra.desktop.enable {
    NIXOS_OZONE_WL = "1";
  };

  wayland.windowManager.hyprland.settings.env = lib.mkIf osConfig.terra.desktop.enable [
      ''__GLX_VENDOR_LIBRARY_NAME,"nvidia"''
  ];
}
