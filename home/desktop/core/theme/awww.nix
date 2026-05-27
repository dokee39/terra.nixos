{ osConfig, inputs, ... }:

let
  awww = inputs.awww.packages.${osConfig.terra.system}.awww;
in {
  home.packages = [ awww ];

  systemd.user.services."awww-daemon" = {
    Unit = {
      Description = "awww wallpaper daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session-pre.target" ];
    };

    Service = {
      ExecStart = "${awww}/bin/awww-daemon";
      Restart = "on-failure";
      RestartSec = 1;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # systemd.user.services."awww-wallpaper" = {
  #   Unit = {
  #     Description = "Set wallpaper with awww";
  #     Requires = [ "awww-daemon.service" ];
  #     After = [ "awww-daemon.service" ];
  #     PartOf = [ "graphical-session.target" ];
  #   };

  #   Service = {
  #     Type = "oneshot";
  #     ExecStart =
  #       "${pkgs.bash}/bin/bash -lc '${pkgs.coreutils}/bin/sleep 1; ${awww}/bin/awww img \"$HOME/Pictures/wallpaper.png\"'";
  #   };

  #   Install = {
  #     WantedBy = [ "graphical-session.target" ];
  #   };
  # };
}
