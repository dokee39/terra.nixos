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
  } // lib.optionalAttrs (
    osConfig.terra.desktop.enable
    && osConfig.terra.gpu.internal.igpuEnabled
    && osConfig.terra.gpu.igpu.vendor == "intel"
  ) {
    LIBVA_DRIVER_NAME = "iHD";
  } // lib.optionalAttrs (
    osConfig.terra.desktop.enable
    && osConfig.terra.gpu.internal.igpuEnabled
    && osConfig.terra.gpu.igpu.vendor == "amd"
  ) {
    LIBVA_DRIVER_NAME = "radeonsi";
  } // lib.optionalAttrs (
    osConfig.terra.desktop.enable
    && !osConfig.terra.gpu.internal.igpuEnabled
    && osConfig.terra.gpu.internal.nvidiaEnabled
  ) {
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
  } // lib.optionalAttrs osConfig.terra.desktop.enable {
    NIXOS_OZONE_WL = "1";
  };
}
