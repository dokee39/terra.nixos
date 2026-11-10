{ config, ... }: {
  imports = [
    ./hardware.nix
  ];

  terra = {
    userName = "dokee";
    maintenance.autoUpgrade.enable = true;
    apps = {
      wechat.scale = 1.5;
      transmission = {
        enable = true;
        speed.up = 1000;
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
            refresh = 120.000;
          };
          scale = 2;
        };
        DP-2 = {
          mode = {
            width = 2560;
            height = 1440;
            refresh = 144.000;
          };
          position = { x = -1080; y = 0; };
          scale = 1.33;
          transform.rotation = 90;
        };
      };
    };
    gpu = {
      nvidia.enable = true;
    };
  };

  boot.kernelModules = [
    "nct6687"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    nct6687d
  ];

  # HACK: Avoid EDIFIER N300 timeouts when resuming from audio suspend.
  services.pipewire.wireplumber.extraConfig."51-no-suspend" = {
    "monitor.alsa.rules" = [{
      matches = [{ "node.name" = "~alsa_output.*"; }];
      actions."update-props"."session.suspend-timeout-seconds" = 0;
    }];
  };

  services.lact.enable = true;
  programs.coolercontrol.enable = true;
  environment.etc."coolercontrol/config.toml" = {
    source = ./coolercontrol/config.toml;
    mode = "0600";
  };

  systemd.tmpfiles.rules = [
    "w- /sys/bus/platform/drivers/amd_x3d_vcache/AMDI0101:*/amd_x3d_mode - - - - cache"
  ];

  boot.loader.grub.useOSProber = true;
}
