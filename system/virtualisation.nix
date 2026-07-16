{ config, lib, ... }:

{
  config = {
    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };

      oci-containers.backend = "podman";
    };

    users.users.${config.terra.userName}.extraGroups = [ "podman" ];

    networking.firewall.trustedInterfaces = [ "podman0" ];

    systemd.timers.podman-auto-update = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
    };
  };

}
