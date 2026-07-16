{ config, lib, ... }:

{
  imports = [
    ./steam.nix
    ./transmission.nix
  ];

  options.terra.apps.wechat.scale = lib.mkOption {
    type = lib.types.nullOr lib.types.number;
    default = lib.mkDefault (
      let p = config.terra.desktop.primaryMonitor; in
      if p != null then config.terra.desktop.monitors.${p}.scale else null
    );
  };
}
