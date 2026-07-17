{ config, lib, pkgs, ... }:

{
  imports = [ ./mihomo.nix ];

  environment.systemPackages = [ pkgs.impala ];

  users.users.${config.terra.userName}.extraGroups = [ "networkmanager" ];

  networking = {
    hostName = config.terra.hostName;
    useDHCP = false;
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      dns = "systemd-resolved";
      dhcp = "internal";
    };
    modemmanager.enable = false;
    wireless.iwd = {
      enable = true;
      settings.Settings.AutoConnect = true;
    };
    proxy = lib.mkIf config.terra.secrets.enable {
      default = lib.mkDefault "http://localhost:7890";
      noProxy = lib.mkDefault "127.0.0.1,localhost,0.0.0.0,::1,api.noctalia.dev";
    };
  };

  services.resolved.enable = true;

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
}
