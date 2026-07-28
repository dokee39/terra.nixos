{ self, config, pkgs, ... }:

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
      name = "MapleBright";
      size = 12.0;
    };

    settings = {
      "symbol_map U+e000-U+e00a,U+e0a0-U+e0a2,U+e0a3,U+e0b0-U+e0b3,U+e0b4-U+e0c8,U+e0ca,U+e0cc-U+e0d7,U+e200-U+e2a9,U+e300-U+e3e3,U+e5fa-U+e6b7,U+e700-U+e8ef,U+ea60-U+ec1e,U+ed00-U+efce,U+f000-U+f2ff,U+f300-U+f381,U+f400-U+f533,U+f0001-U+f1af0" = "Maple Mono NF CN";

      cursor_trail = 5;
      enabled_layouts = "splits";
      window_padding_width = 12;
      confirm_os_window_close = 0;
      background_opacity = 0.8;
      resize_debounce_time = "0 0";
      placement_strategy = "top-left";
    };

    keybindings = {
      "ctrl+alt+n" = "launch --type=background --cwd=current ${pkgs.kitty}/bin/kitty --detach";
    };
  };

  xdg.configFile."kitty/kitty.app.png".source = "${self}/assets/rose-pine-kitty-icon.png";
}
