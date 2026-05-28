{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    package = pkgs.kitty.overrideAttrs (o: {
      postInstall = (o.postInstall or "") + ''
        substituteInPlace $out/share/applications/kitty.desktop \
          --replace-fail "Icon=kitty" "Icon=${config.xdg.configHome}/kitty/kitty.app.png"
      '';
    });

    themeFile = "rose-pine-moon";

    shellIntegration = {
      enableFishIntegration = true;
    };

    font = {
      name = "Maple Mono NF CN";
      size = 12.0;
    };

    settings = {
      "symbol_map U+4E00-U+9FFF,U+FF00-U+FFEF,U+3000-U+303F,U+3040-U+309F,U+30A0-U+30FF,U+31F0-U+31FF,U+1B000-U+1B0FF,U+AC00-U+D7AF,U+1100-U+11FF,U+3130-U+318F" = "LXGWWenKaiMono Nerd Font";

      cursor_trail = 5;
      enabled_layouts = "splits";
      window_padding_width = 12;
      confirm_os_window_close = 0;
      background_opacity = 0.8;
      resize_debounce_time = "0 0";
      placement_strategy = "top-left";
    };
  };

  xdg.configFile."kitty/kitty.app.png".source = ../assets/rose-pine-kitty-icon.png;
}
