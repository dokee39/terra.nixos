{ lib, pkgs, customPackages, ... }:

let
  settings = pkgs.writeText "aegisub-config.json" (builtins.toJSON {
    Subtitle = {
      "Edit Box"."Font Size" = 22;
      Grid."Font Size" = 12;
    };
    Colour = {
      "Subtitle Grid" = {
        Background = {
          Background = "rgb(45, 45, 45)";
          Comment = "rgb(30, 30, 30)";
          Inframe = "rgb(55, 55, 61)";
          "Selected Comment" = "rgb(38, 79, 120)";
          Selection = "rgb(9, 71, 113)";
        };
        "CPS Error" = "rgb(244, 71, 71)";
        Collision = "rgb(255, 111, 111)";
        Header = "rgb(55, 55, 55)";
        "Left Column" = "rgb(55, 55, 55)";
        Lines = "rgb(85, 85, 85)";
        Selection = "rgb(255, 255, 255)";
        Standard = "rgb(220, 220, 220)";
      };
      Subtitle = {
        Background = "rgb(30, 30, 30)";
        Syntax = {
          Background.Error = "rgb(91, 0, 0)";
          Brackets = "rgb(246, 170, 17)";
          Comment = "rgb(106, 153, 85)";
          Error = "rgb(244, 71, 71)";
          "Karaoke Template" = "rgb(197, 134, 192)";
          "Karaoke Variable" = "rgb(197, 134, 192)";
          "Line Break" = "rgb(128, 128, 128)";
          Normal = "rgb(220, 220, 220)";
          Parameters = "rgb(206, 145, 120)";
          Slashes = "rgb(86, 156, 214)";
          Tags = "rgb(86, 156, 214)";
        };
      };
    };
  });

  hotkeys = pkgs.writeText "aegisub-hotkey.json" (builtins.toJSON {
    Default = {
      "grid/line/next" = [ "Tab" ];
      "grid/line/prev" = [ "Shift-Tab" ];
    };
  });
in {
  home.activation.aegisubPreferences = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mergeAegisub() {
      local file="$HOME/.aegisub/$1.json" preferences="$2" base="$3" tmp
      if [ -f "$file" ]; then
        base="$file"
      fi
      tmp=$(mktemp "$file.XXXXXX")
      jq -s '.[0] * .[1]' "$base" "$preferences" > "$tmp"
      mv "$tmp" "$file"
    }

    run mkdir -p "$HOME/.aegisub"
    run mergeAegisub config ${settings} ${settings}
    run mergeAegisub hotkey ${hotkeys} ${customPackages.aegisub.src}/src/libresrc/default_hotkey.json
  '';
}
