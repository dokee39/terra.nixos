{ config, lib, ... }:

{
  options.terra.virtualisation.proxyEnv = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = rec {
      http_proxy = "";
      HTTP_PROXY = http_proxy;
      https_proxy = http_proxy;
      HTTPS_PROXY = http_proxy;
      ftp_proxy = http_proxy;
    };
    readOnly = true;
    internal = true;
  };

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
