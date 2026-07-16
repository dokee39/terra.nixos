{ ... }:

{
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  services.fstrim.enable = true;
  services.smartd = {
    enable = true;
    notifications.systembus-notify.enable = true;
  };
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=30day
  '';
  systemd.tmpfiles.rules = [
    "q /var/tmp - - - 30d"
    "e /var/cache - - - 30d"
  ];
  systemd.user.tmpfiles.rules = [
    "e %C - - - 30d"
  ];
}
