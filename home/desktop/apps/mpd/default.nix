{ config, ... }:

{
  programs.rmpc.enable = true;
  xdg.configFile.rmpc.source = ./rmpc;

  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    extraConfig = ''
      audio_output {
        type   "pipewire"
        name   "PipeWire"
      }
      auto_update       "yes"
      auto_update_depth "4"
      restore_paused    "yes"
      replaygain        "auto"
    '';
  };
}
