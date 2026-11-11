{ config, lib, ... }: {
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

  services.memos = {
    enable = true;
    settings = {
      MEMOS_ADDR = "127.0.0.1";
      MEMOS_PORT = "5230";
      MEMOS_DATA = config.services.memos.dataDir;
      MEMOS_INSTANCE_URL = "https://nixos-mini.taila9e231.ts.net";
    };
  };

  systemd.services.memos.serviceConfig.Restart = "on-failure";

  systemd.services.memos-serve = {
    description = "Memos HTTPS via Tailscale Serve";
    wantedBy = [ "multi-user.target" ];
    after = [ "tailscaled.service" "memos.service" ];
    wants = [ "tailscaled.service" "memos.service" ];
    serviceConfig = {
      ExecStart = "${lib.getExe config.services.tailscale.package} serve --https=443 --yes http://127.0.0.1:5230";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
