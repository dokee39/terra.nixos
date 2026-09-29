{ lib, osConfig, pkgs, sources, ... }:

let
  scale = osConfig.terra.apps.wechat.scale;
  appId = sources.wechat.appId;
  launcher = pkgs.writeShellApplication {
    name = "wechat";
    runtimeInputs = [ pkgs.flatpak ];
    text = ''
      flatpak run --user ${appId} "$@"
    '';
  };
in
{
  home.packages = [ launcher ];

  services.flatpak = {
    packages = [ { inherit (sources.wechat) appId origin commit; } ];
    overrides.${appId} = {
      Context.filesystems = [ "xdg-download" "xdg-pictures" ];
      Environment = lib.optionalAttrs (scale != null) {
        QT_AUTO_SCREEN_SCALE_FACTOR = "0";
        QT_SCALE_FACTOR = toString scale;
      };
    };
  };
}
