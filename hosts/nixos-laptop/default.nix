{ ... }: {
  imports = [ ./hardware.nix ];

  terra = {
    userName = "dokee";

    desktop = {
      enable = true;
      monitors."eDP-1" = {
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
    };

    gpu = {
      intelIgpu.enable = false;
      nvidia = {
        enable = true;
        prime.intelBusId = null;
        prime.nvidiaBusId = null;
      };
    };

    apps = {
      transmission.enable = true;
    };
  };
}
