{ config, lib, ... }:

let
  cfg = config.terra.maintenance;
in {
  options.terra.maintenance.autoUpgrade = {
    enable = lib.mkEnableOption "automatic NixOS upgrades";

    mode = lib.mkOption {
      type = lib.types.enum [ "boot" "switch" "reboot" ];
      default = "boot";
      description = "Controls system.autoUpgrade.operation and system.autoUpgrade.allowReboot.";
    };
  };

  config = {
    system.autoUpgrade = {
      enable = cfg.autoUpgrade.enable;
      flake = "github:dokee39/terra.nixos#${config.terra.hostName}";
      upgrade = false;
      operation = if cfg.autoUpgrade.mode == "boot" then "boot" else "switch";
      dates = "Sun 12:30";
      allowReboot = cfg.autoUpgrade.mode == "reboot";
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    services.fstrim.enable = true;
    services.smartd = {
      enable = true;
      notifications.systembus-notify.enable = true;
    };
    services.journald.settings.Journal = {
      SystemMaxUse = "500M";
      MaxRetentionSec = "30day";
    };
    systemd.tmpfiles.rules = [
      "q /var/tmp - - - 30d"
      "e /var/cache - - - 30d"
    ];
    systemd.user.tmpfiles.rules = [
      "e %C - - - 30d"
    ];
  };
}
