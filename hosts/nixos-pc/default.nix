{ config, pkgs, pkgs-stable, ... }: {
  imports = [
    ./hardware.nix
  ];

  terra = {
    userName = "dokee";
    apps = {
      wechat.scale = 1.3;
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
      monitors = {
        HDMI-A-1 = {
          primary = true;
          mode = {
            width = 3840;
            height = 2160;
            refresh = 120;
          };
          scale = 2;
        };
        DP-3 = {
          mode = {
            width = 2560;
            height = 1440;
            refresh = 144;
          };
          position = { x = -1080; y = 0; };
          scale = 1.33;
          transform = { rotation = 90; flipped = false; };
        };
      };
    };
    gpu = {
      nvidia.enable = true;
    };
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:dokee39/terra.nixos#${config.terra.hostName}";
    upgrade = false;
    operation = "boot";
    dates = "Sun 12:30";
  };

  boot.kernelModules = [
    "nct6687"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    nct6687d
  ];

  services.lact = {
    enable = true;
    # HACK: lact 0.9.1 build error
    package = pkgs.lact.override {
      libdisplay-info = pkgs-stable.libdisplay-info;
    };
  };
  programs.coolercontrol.enable = true;
  environment.etc."coolercontrol/config.toml" = {
    source = ./coolercontrol/config.toml;
    mode = "0600";
  };

  systemd.tmpfiles.rules = [
    "w- /sys/bus/platform/drivers/amd_x3d_vcache/AMDI0101:*/amd_x3d_mode - - - - cache"
  ];

  # TODO
  systemd.settings.Manager = {
    RuntimeWatchdogSec = "60s";
    RebootWatchdogSec = "60s";
  };
  boot.initrd.kernelModules = [ "pci_stub" ];
  boot.kernelParams = [
    "pci-stub.ids=1022:43f7"
  ];
}
