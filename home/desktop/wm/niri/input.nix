{ ... }:

{
  wayland.windowManager.niri.settings.input = {
    disable-power-key-handling = { };
    workspace-auto-back-and-forth = { };
    focus-follows-mouse._props.max-scroll-amount = "0%";
    keyboard = {
      numlock = { };
      repeat-delay = 500;
    };
    touchpad = {
      tap = { };
      natural-scroll = { };
    };
    mouse = {
      scroll-factor = 1.2;
    };
  };
}
