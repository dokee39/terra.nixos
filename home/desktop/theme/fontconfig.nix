{ ... }:

{
  fonts.fontconfig = {
    enable = true;
    antialiasing = true;
    hinting = "full";

    defaultFonts = {
      serif = [
        "Noto Serif"
        "Noto Serif CJK SC"
        "Libertinus Serif"
        "DejaVu Serif"
      ];

      sansSerif = [
        "Inter"
        "Noto Sans CJK SC"
        "LXGW Neo XiHei"
        "DejaVu Sans"
      ];

      monospace = [
        "Maple Mono NF CN"
        "DejaVu Sans Mono"
      ];

      emoji = [
        "Noto Color Emoji"
      ];
    };

    configFile = {
      cjk-aliases = {
        enable = true;
        priority = 60;
        text = ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
          <fontconfig>
            <description>Alias common Chinese font families</description>

            <match target="pattern">
              <test qual="any" name="family"><string>WenQuanYi Zen Hei</string></test>
              <edit name="family" mode="assign" binding="same">
                <string>Noto Sans CJK SC</string>
              </edit>
            </match>

            <match target="pattern">
              <test qual="any" name="family"><string>WenQuanYi Micro Hei</string></test>
              <edit name="family" mode="assign" binding="same">
                <string>Noto Sans CJK SC</string>
              </edit>
            </match>

            <match target="pattern">
              <test qual="any" name="family"><string>WenQuanYi Micro Hei Light</string></test>
              <edit name="family" mode="assign" binding="same">
                <string>Noto Sans CJK SC</string>
              </edit>
            </match>

            <match target="pattern">
              <test qual="any" name="family"><string>Microsoft YaHei</string></test>
              <edit name="family" mode="assign" binding="same">
                <string>Noto Sans CJK SC</string>
              </edit>
            </match>

            <match target="pattern">
              <test qual="any" name="family"><string>SimHei</string></test>
              <edit name="family" mode="assign" binding="same">
                <string>Noto Sans CJK SC</string>
              </edit>
            </match>

            <match target="pattern">
              <test qual="any" name="family"><string>SimSun</string></test>
              <edit name="family" mode="assign" binding="same">
                <string>Noto Serif CJK SC</string>
              </edit>
            </match>

            <match target="pattern">
              <test qual="any" name="family"><string>SimSun-18030</string></test>
              <edit name="family" mode="assign" binding="same">
                <string>Noto Serif CJK SC</string>
              </edit>
            </match>

            <match target="font">
              <test qual="any" name="family">
                <string>Noto Color Emoji</string>
              </test>
              <edit name="embeddedbitmap" mode="assign">
                <bool>true</bool>
              </edit>
            </match>
          </fontconfig>
        '';
      };
    };
  };
}
