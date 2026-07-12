{ config, lib, pkgs, ... }:

{
  options.terra = {
    userName = lib.mkOption {
      type = lib.types.str;
      description = "User name";
    };
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "Host name";
    };

    authorizedSshKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "SSH public keys authorized for the primary user.";
    };

    nix.githubPat_secretFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a secret file containing the GitHub PAT for nix.";
    };

    system = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      internal = true;
      default = pkgs.stdenv.hostPlatform.system;
    };
    shellPkg = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      internal = true;
      default = config.users.users.${config.terra.userName}.shell or pkgs.bashInteractive;
    };
    shellExe = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      internal = true;
      default = lib.getExe config.terra.shellPkg;
    };
  };
}
