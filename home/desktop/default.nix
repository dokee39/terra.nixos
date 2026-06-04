{ pkgs, lib, inputs, osConfig, ... }:

let
  customPackages = import ./packages {
    inherit pkgs inputs osConfig;
  };
in

{
  _module.args = {
    inherit customPackages;
  };

  imports = [
    ./core
    ./apps/kitty.nix
    ./apps/misc.nix
    ./apps/nautilus.nix
    ./apps/mpv.nix
    ./apps/mpd
  ];

  xdg.portal.enable = lib.mkForce false;

  home.packages =
    (with pkgs; [
      ddcutil
      playerctl
      brightnessctl
      pulsemixer
      hyprpicker

      google-chrome
      osu-lazer-bin
      cherry-studio
      xwayland-satellite
    ])
    ++ [
      customPackages.mikan
      customPackages.qq
      customPackages.wechat
    ];
}
