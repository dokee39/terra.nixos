{ config, pkgs, lib, ... }:

let
  cfg = config.terra;
  sshKeys = import ../secrets/keys.nix;
in {
  imports = [
    ./apps
    ./base
    ./network
    ./desktop.nix
    ./virtualisation.nix
    ./nix.nix
  ];

  options.terra = {
    userName = lib.mkOption {
      type = lib.types.str;
      description = "User name";
    };
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "Host name";
    };
    system = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      internal = true;
      default = pkgs.stdenv.hostPlatform.system;
    };
  };

  config = {
    users.users.${cfg.userName} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "storage"
        "power"
        "audio"
        "video"
        "uucp"
        "input"
        "i2c"
      ];
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = sshKeys.users;
    };

    time.timeZone = "Asia/Shanghai";
    i18n.defaultLocale = "en_GB.UTF-8";
  };
}
