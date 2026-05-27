{ config, lib, ... }:

{
  programs.tofi = {
    enable = true;
    settings = {
      font = "LXGW Bright";
      font-size = 14;

      text-color = "#C2FFDF";
      prompt-color = "#E6C000";
      input-color = "#FECD5E";
      default-result-background-padding = "4, 10";
      selection-color = "#000000";
      selection-background = "#C2FFFF";
      selection-background-padding = "3, 8";
      selection-background-corner-radius = 6;

      placeholder-text = "...";
      result-spacing = 8;

      width = 800;
      height = 360;
      background-color = "#1D19299F";
      outline-width = 0;
      border-width = 3;
      border-color = "#BBA0F0";
      corner-radius = 24;
      padding-top = 6;
      padding-bottom = 6;
      padding-left = 12;
      padding-right = 12;

      text-cursor = true;
    };
  };

  home.activation.clearTofiCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD rm -f \
      "${config.xdg.cacheHome}/tofi-drun" \
      "${config.xdg.cacheHome}/tofi-compgen"
  '';

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "LXGW Bright:size=15";
        placeholder = "...";
        width = 60;
        lines = 8;
        line-height = 24;
        horizontal-pad = 34;
        vertical-pad = 16;
        inner-pad = 16;
        layer = "overlay";
        icons-enabled = false;
      };

      colors = {
        background = "1d19299f";
        text = "c2ffdfff";
        prompt = "e6c000ff";
        input = "fecd5eff";
        selection = "c2ffffff";
        selection-text = "000000ff";
        match = "c2ffdf";
        border = "bba0f0ff";
      };

      border = {
        width = 3;
        radius = 24;
        selection-radius = 8;
      };
    };
  };
}
