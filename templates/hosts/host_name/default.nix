{ config, pkgs, ... }:

{
  imports = [ ./hardware.nix ];

  terra = {
    userName = "user_name";
    authorizedSshKeys = [ ];
    nix.githubPat_secretFile = ./path/to/secret/file.age;
    mihomo = {
      port = 7890;
      tunDevice = "tun0";
      subscriptionUrl_secretFile = ./path/to/secret/file.age;
    };

    ai = {
      mongodb.port = 27017;
      meilisearch= {
        port = 7700;
        masterKey_secretFile = ./path/to/secret/file.age;
      };

      librechat = {
        enable = true;
        port = 3080;
        credentials_secretFile = ./path/to/secret/file.age;
        meilisearchMasterKey_secretFile = ./path/to/secret/file.age;
      };

      mcp = {
        groupName = "mcp";
        github = {
          enable = true;
          pat_secretFile = ./path/to/secret/file.age;
        };
        web = {
          enable = true;
          crawl4aiPort = 11235;
          shmSize = "2g";
          env_secretFile = ./path/to/secret/file.age;
        };
      };
    };

    transmission = {
      enable = false;
      speed = {
        up = 200;
        down = 2000;
      };
      alt-speed = {
        up = 2000;
        down = 10000;
      };
      rpc_secretFile = ./path/to/secret/file.age;
    };

    desktop = {
      enable = false;
      monitors.DP-1 = {
        primary = true;
        mode =  "2560x1440@120";
        position = { x = 2560; y = 0; };
        scale = 1;
        transform = "normal";
      };
      wechat.scale = 1;
    };

    gpu = {
      intelIgpu.enable = false;
      nvidia = {
        enable = false;
        prime = {
          intelBusId = null;
          nvidiaBusId = null;
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
