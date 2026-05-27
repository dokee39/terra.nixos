{ ... }:

{
  programs.niri.settings.input = {
    power-key-handling.enable = false;
    warp-mouse-to-focus = {
      enable = true;
      mode = "center-xy";
    };
    workspace-auto-back-and-forth = true;
    focus-follows-mouse = {
      enable = true;
      max-scroll-amount = "0%";
    };
    keyboard = {
      numlock = true;
      repeat-rate = 25;
      repeat-delay = 500;
    };
    mouse = {
      scroll-factor = 1.2;
    };
  };
}
