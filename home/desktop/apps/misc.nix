{ pkgs, ... }:

{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
      obs-vkcapture
    ];
  };

  programs.imv = {
    enable = true;
    settings = {
      options = {
        background = "#232136";
        fullscreen = false;
        overlay = false;
        overlay_text_color = "#dcd7ba";
        overlay_background_color = "#363646";
        overlay_background_alpha = "ff";
        overlay_font = "Maple Mono NF CN:12";
        overlay_position_bottom = true;
      };
    };
  };
}
