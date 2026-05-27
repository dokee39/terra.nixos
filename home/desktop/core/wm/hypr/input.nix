{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    input = {
      repeat_rate = 30;
      repeat_delay = 500;

      accel_profile = "flat";
      scroll_factor = 1.2;

      touchpad = {
        natural_scroll = true;
      };

      tablet = {
        transform = 2;
        output = "current";
      };
    };
  };
}
