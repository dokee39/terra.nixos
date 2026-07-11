{ config, lib, ... }:

{
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
