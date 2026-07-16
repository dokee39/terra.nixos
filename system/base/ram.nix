{ ... }:

{
  boot.tmp.useTmpfs = false;
  boot.tmp.cleanOnBoot = true;

  zramSwap = {
    enable = true;
    memoryPercent = 20;
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
    }
  ];

  systemd.oomd = {
    enableRootSlice = true;
    enableSystemSlice = true;
    enableUserSlices = true;
  };

  systemd.services.sshd.serviceConfig.OOMScoreAdjust = -900;
  systemd.services.systemd-logind.serviceConfig.OOMScoreAdjust = -500;
  systemd.services.iwd.serviceConfig.OOMScoreAdjust = -500;
  systemd.services.systemd-networkd.serviceConfig.OOMScoreAdjust = -500;
  systemd.services.systemd-resolved.serviceConfig.OOMScoreAdjust = -500;
}
