{ ... }: {
  imports = [
    ./wm/niri
    ./shell/noctalia.nix
    ./shell/launcher.nix
    ./shell/clipse.nix
    ./theme/cursor.nix
    ./theme/fontconfig.nix
    ./theme/gtk-qt-theme.nix
    ./fcitx5.nix
    ./downloads-sorter.nix
    ./mime.nix
    ./pipewire.nix
  ];
}
