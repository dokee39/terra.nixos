{ ... }: {
  imports = [ ./hardware.nix ];

  terra = {
    userName = "dokee";
    hardware.hasBattery = true;
    maintenance.autoUpgrade.enable = true;

    desktop = {
      enable = true;
      monitors = {
        "eDP-1" = {
          primary = true;
          mode = {
            width = 2560;
            height = 1600;
            refresh = 165;
          };
          position = { x = 0; y = 0; };
          scale = 1.6;
          transform = { rotation = 0; flipped = false; };
        };
        "HDMI-A-1" = {
          mode = {
            width = 3840;
            height = 2160;
            refresh = 60;
          };
          position = { x = 0; y = -1080; };
          scale = 2;
          transform = { rotation = 0; flipped = false; };
        };
      };
    };

    gpu = {
      igpu = {
        enable = true;
        vendor = "intel";
        busId = "PCI:0@0:2:0";
      };
      nvidia = {
        enable = true;
        busId = "PCI:1@0:0:0";
      };
    };

    apps = {
      transmission.enable = true;
    };
  };

  boot.loader.grub.useOSProber = true;
}
