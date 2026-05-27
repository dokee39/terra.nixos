{ pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      uosc
      thumbfast
      mpris
    ];
    defaultProfiles = [ "high-quality" ];
    config = {
      hwdec = "auto";

      screenshot-directory = "~/Downloads";
      screenshot-template = "%F-%{estimated-frame-number:%P}";
      screenshot-format = "png";

      save-position-on-quit = true;
      keep-open = true;

      osd-bar = false;
      border = false;
      osc = false;

      sub-auto = "fuzzy";
      sub-file-paths = [
        "sub"
        "subs"
        "subtitle"
        "subtitles"
      ];
      sub-ass-override = "no";

      cscale = "catmull_rom";
      deband = true;
      icc-profile-auto = true;
      blend-subtitles = "video";
      video-sync = "display-resample";
      interpolation = true;
    };
  };
}
