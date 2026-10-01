{ ... }: {
  imports = [ ./hardware.nix ];

  terra = {
    userName = "dokee";
    boot.grubTimeOut = 0;
    maintenance.autoUpgrade = {
      enable = true;
      mode = "reboot";
    };

    apps = {
      transmission = {
        enable = true;
        speed = { up = 200; down = 10000; };
        alt-speed = { up = 2000; down = 100000; };
      };
    };
  };
}
