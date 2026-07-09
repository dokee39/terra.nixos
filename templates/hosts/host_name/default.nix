{ config, pkgs, ... }:

{
  imports = [ ./hardware.nix ];

  terra = {
    userName = "user_name";
    authorizedSshKeys = [ ];
    nix.githubPat_secretFile = ./.empty;
    mihomo = {
      port = 7890;
      tunDevice = "tun0";
      subscriptionUrl_secretFile = ./.empty;
    };

    ai = {
      mongodb.port = 27017;
      meilisearch= {
        port = 7700;
        masterKey_secretFile = ./.empty;
      };

      librechat = {
        enable = true;
        port = 3080;
        credentials_secretFile = ./.empty;
      };

      mcp = {
        groupName = "mcp";
        github = {
          enable = true;
          pat_secretFile = ./.empty;
        };
        web = {
          enable = true;
          crawl4aiPort = 11235;
          shmSize = "2g";
          env_secretFile = ./.empty;
        };
      };
    };

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
      rpc_secretFile = ./.empty;
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
        position = {
          niri = { x = -1080; y = 0; };
          hyprland = "auto-left";
        };
        scale = 1;
        transform = "normal";
      };

      wechat.scale = 1;
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
    enable = false;
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

  programs.coolercontrol.enable = false;
  services.lact.enable = false;
}
