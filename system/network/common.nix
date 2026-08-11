{ config, inputs, lib, pkgs, ... }:

let
  cfg = config.terra.mihomo;
in
{
  options.terra.mihomo.tunDevice = lib.mkOption {
    type = lib.types.str;
    default = "tun0";
  };

  config = {
    environment.systemPackages = with pkgs; [
      clashtui
      impala
    ];

    networking = {
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

      firewall.trustedInterfaces = [ cfg.tunDevice ];
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
        PasswordAuthentication = lib.mkDefault false;
      };
    };

    services.mihomo = {
      enable = true;
      tunMode = true;
      processesInfo = true;
      configFile = "/var/lib/private/mihomo/config.yaml";
    };

    system.activationScripts.mihomo-mmdb.text = ''
      install -d -m 0755 /var/lib/private/mihomo
      install -m 0644 \
        "${inputs.mmdb}/Country.mmdb" \
        /var/lib/private/mihomo/Country.mmdb
    '';
  };
}
