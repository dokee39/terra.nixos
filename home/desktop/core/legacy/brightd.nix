{ lib, customPackages, osConfig, ... }:

{
  home.packages = [ customPackages.brightd ];

  xdg.configFile."ddcutil/ddcutilrc".text = ''
    [ddcutil]
    options: --syslog NEVER
  '';

  xdg.configFile."brightd/config.toml".text =
    lib.concatStringsSep "\n\n"
      (lib.mapAttrsToList
        (name: m: ''
          [${name}]
          device = "${m.brightd.device}"
          brightness.min = ${toString m.brightd.brightness.min}
          brightness.max = ${toString m.brightd.brightness.max}
        '')
        osConfig.terra.desktop.monitors);

  systemd.user.services.brightd = {
    Unit = {
      Description = "brightd brightness worker";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${lib.getExe customPackages.brightd} worker";
      ExecReload = "${lib.getExe customPackages.brightd} ctl reload";
      Restart = "on-failure";
      RestartSec = 1;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
