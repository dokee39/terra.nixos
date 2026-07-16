{ pkgs, inputs, osConfig, ... }:

let
  mkNixPak = inputs.nixpak.lib.nixpak {
    inherit (pkgs) lib;
    pkgs = pkgs;
  };

  desktopContext = {
    nvidiaEnabled = osConfig.terra.gpu.internal.nvidiaEnabled;
    wechatScaleFactor = osConfig.terra.apps.wechat.scale;
  };
in
{
  qq = pkgs.callPackage ./qq.nix {
    inherit mkNixPak desktopContext;
  };

  wechat = pkgs.callPackage ./wechat.nix {
    inherit mkNixPak desktopContext;
  };
}
