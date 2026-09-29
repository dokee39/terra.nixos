{ lib, osConfig, pkgs, sources, ... }:

let
  scale = osConfig.terra.apps.wechat.scale;
  launcher = pkgs.writeShellApplication {
    name = "wechat";
    runtimeInputs = [ pkgs.flatpak ];
    text = ''
      flatpak run --user com.tencent.WeChat "$@"
    '';
  };
in
{
  home.packages = [ launcher ];

  services.flatpak = {
    packages = [ { inherit (sources.wechat) appId origin commit; } ];
    overrides."com.tencent.WeChat" = {
      Context.filesystems = [ "xdg-download" "xdg-pictures" ];
      Environment = lib.optionalAttrs (scale != null) {
        QT_AUTO_SCREEN_SCALE_FACTOR = "0";
        QT_SCALE_FACTOR = toString scale;
      };
    };
  };
}
