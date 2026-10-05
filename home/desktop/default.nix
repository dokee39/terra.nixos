{ pkgs, inputs, sources, ... }:

let
  customPackages = import ./packages {
    inherit pkgs inputs sources;
  };
in

{
  _module.args = {
    inherit customPackages;
  };

  imports = [
    ./mime.nix
    ./services/downloads-sorter.nix
    ./services/fcitx5.nix
    ./services/pipewire.nix
    ./services/syncthing.nix
    ./shell/clipse.nix
    ./shell/launcher.nix
    ./shell/noctalia.nix
    ./theme/cursor.nix
    ./theme/fontconfig.nix
    ./theme/gtk-qt-theme.nix
    ./wm/niri
    ./apps/aegisub.nix
    ./apps/flatpak
    ./apps/kitty.nix
    ./apps/misc.nix
    ./apps/nautilus.nix
    ./apps/mpv.nix
    ./apps/mpd
  ];

  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
  ];

  home.packages =
    (with pkgs; [
      ddcutil
      playerctl
      brightnessctl
      pulsemixer
      hyprpicker

      xwayland-satellite

      google-chrome
      pinta
      osu-lazer-bin
    ])
    ++ (with customPackages; [
      mikan
      aegisub
    ]);
}
