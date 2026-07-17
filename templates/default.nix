{ ... }: {
  imports = [ ./hardware.nix ];

  terra = {
    userName = "user_name";
    secrets.enable = true;

    boot.grubTimeOut = 1;

    desktop = {
      enable = false;
      monitors."eDP-1" = {
        primary = false;
        mode = {
          width = 1920;
          height = 1080;
          refresh = null;
        };
        position = { x = 0; y = 0; };
        scale = 1;
        transform = { rotation = 0; flipped = false; };
      };
    };

    gpu = {
      intelIgpu.enable = false;
      nvidia = {
        enable = false;
        prime.intelBusId = null;
        prime.nvidiaBusId = null;
      };
    };

    apps = {
      wechat.scale = null;

      transmission = {
        enable = false;
        speed = { up = 200; down = 2000; };
        alt-speed = { up = 2000; down = 10000; };
      };
    };

    mihomo.tunDevice = "tun0";
  };

  # networking.proxy = {
  #   default = "http://localhost:7890";
  #   noProxy = "127.0.0.1,localhost,0.0.0.0,::1";
  # };

  # system.autoUpgrade = {
  #   enable = false;
  #   flake = "github:dokee39/terra.nixos#${config.terra.hostName}";
  #   operation = "boot";
  #   dates = "Sun 12:30";
  # };
}
