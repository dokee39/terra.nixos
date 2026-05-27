{ ... }: {
  imports = [
    ./wm/niri
    ./wm/hypr
    ./shell/ags
    ./shell/launcher.nix
    ./shell/mako.nix
    ./shell/clipse.nix
    ./theme/awww.nix
    ./theme/cursor.nix
    ./theme/fontconfig.nix
    ./theme/gtk-qt-theme.nix
    ./brightd.nix
    ./fcitx5.nix
    ./downloads-sorter.nix
    ./mime.nix
    ./polkit.nix
  ];
}
