{ pkgs, config, ... }:

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
      hwdec = "nvdec-copy";

      screenshot-directory = "~/Downloads";
      screenshot-template = "%F-%{estimated-frame-number:%P}";
      screenshot-format = "png";

      save-position-on-quit = true;
      keep-open = true;

      osd-bar = false;
      border = false;
      osc = false;

      sub-auto = "fuzzy";
      sub-file-paths = "sub:subs:subtitle:subtitles";
      sub-ass-override = "no";
      sub-fonts-dir = "Fonts";

      cscale = "catmull_rom";
      deband = true;
      icc-profile-auto = true;
      blend-subtitles = "video";
      video-sync = "display-resample";
      interpolation = true;
    };
  };

  xdg.configFile."mpv/fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <include ignore_missing="yes">/etc/fonts/fonts.conf</include>
      <dir>${config.home.homeDirectory}/.local/share/anime-fonts</dir>
      <dir>${pkgs.mpvScripts.uosc}/share/fonts</dir>
    </fontconfig>
  '';
}
