{ pkgs, sources, ... }:

let
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
    overrides.${appId}.Context.filesystems = [ "xdg-download" "xdg-pictures" ];
  };
}
