{ pkgs, ... }:

let
  cursorSize = 24;
  xcursorName = "BreezeX-RosePine-Linux";
in
{
  home.packages = with pkgs; [
    rose-pine-cursor
  ];

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;

    package = pkgs.rose-pine-cursor;
    name = xcursorName;
    size = cursorSize;
  };

  dconf.settings."org/gnome/desktop/interface" = {
    cursor-theme = xcursorName;
    cursor-size = cursorSize;
  };

  home.sessionVariables = {
    XCURSOR_THEME = xcursorName;
    XCURSOR_SIZE  = toString cursorSize;
  };

}
