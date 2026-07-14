{ pkgs, ... }:

{
  xdg.mimeApps = {
    enable = true;
    defaultApplicationPackages = with pkgs; [
      google-chrome
      mpv
      imv
    ];
    defaultApplications = {
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
    };
  };
}
