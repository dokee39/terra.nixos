{ config, lib, pkgs, ... }:

{
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
    proxy = {
      default = lib.mkDefault "http://localhost:${toString config.terra.mihomo.port}";
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
