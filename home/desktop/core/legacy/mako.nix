{ ... }:

{
  services.mako = {
    enable = true;

    settings = {
      background-color = "#1d19295f";
      width = 360;
      height = 150;
      border-size = 3;
      border-color = "#bba0f0ee";
      border-radius = 12;
      icons = 0;
      default-timeout = 5000;
      font = "LXGW Bright 12";
      margin = 12;
      padding = "12,20";
      progress-color = "source #b2ffff3f";

      "urgency=low" = {
        border-color = "#908caaee";
      };

      "urgency=normal" = {
        border-color = "#c5a3ffee";
      };

      "urgency=critical" = {
        border-color = "#b2ffffee";
        default-timeout = 0;
      };
    };
  };
}
