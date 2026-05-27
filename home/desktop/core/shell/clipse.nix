{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
  ];

  services.clipse = {
    enable = true;

    keyBindings = {
      up = "k";
      down = "j";
      end = "ctrl+l";
      home = "ctrl+h";
      nextPage = "l";
      prevPage = "h";
      preview = "tab";
      remove = "d";
      selectDown = " ";
      selectUp = "S";
      togglePinned = "v";
    };

    imageDisplay = {
      type = "kitty";
      scaleX = 18;
      scaleY = 18;
      heightCut = 4;
    };
  };
}
