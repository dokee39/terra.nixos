{ config, lib, ... }:

{
  imports = [
    ./common.nix
    ./mihomo.nix
  ];

  users.users.${config.terra.userName}.extraGroups = [ "networkmanager" ];

  networking = {
    hostName = config.terra.hostName;
    proxy = {
      default = lib.mkDefault "http://localhost:7890";
      noProxy = lib.mkDefault "127.0.0.1,localhost,0.0.0.0,::1,api.noctalia.dev";
    };
  };
}
