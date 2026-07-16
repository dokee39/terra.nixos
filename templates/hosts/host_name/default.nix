{ config, pkgs, ... }:

{
  imports = [ ./hardware.nix ];

  terra = {
    userName = "user_name";
    boot.grubTimeOut = 1;
    mihomo = {
      tunDevice = "tun0";
    };

    apps = {
      wechat.scale = 1;
      transmission = {
        enable = true;
        speed = {
          up = 200;
          down = 2000;
        };
        alt-speed = {
          up = 2000;
          down = 10000;
        };
      };
    };

    desktop = {
      enable = true;

      monitors.DP-1 = {
        primary = true;
        mode = {
          width = 2560;
          height = 1440;
          refresh = 120;
        };
        position = { x = -1080; y = 0; };
        scale = 1;
        transform = { rotation = 0; flipped = false; };
      };
    };

    gpu = {
      intelIgpu.enable = true;
      nvidia = {
        enable = true;
        prime = {
          intelBusId = "PCI:0@0:2:0";
          nvidiaBusId = "PCI:1@0:0:0";
        };
      };
    };
  };

  # optional
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.timeout = 1;

  system.autoUpgrade = {
    enable = true;
    flake = "github:yourname/your-config#${config.terra.hostName}";
    dates = "Sun *-*-* 04:40:00";
    operation = "boot";
    flags = [ "--refresh" ];
  };

  networking = { # force
    proxy = {
      default = "http://localhost:7890";
      noProxy = "localhost";
    };
  };

  programs.coolercontrol.enable = true;
  services.lact.enable = true;
}
