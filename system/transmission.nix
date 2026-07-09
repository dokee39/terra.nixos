{ lib, config, pkgs, ... }:

{
  options.terra.transmission = {
    enable = lib.mkEnableOption "Transmission";

    speed = {
      up = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 200;
        description = "Normal upload speed in kB/s.";
      };

      down = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 2000;
        description = "Normal download speed in kB/s.";
      };
    };

    alt-speed = {
      up = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 2000;
        description = "Alternative upload speed in kB/s.";
      };

      down = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 10000;
        description = "Alternative download speed in kB/s.";
      };
    };

    rpc_secretFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a secret file containing `transmission-rpc.json`.";
    };
  };

  config =
    let
      cfg = config.terra.transmission;
      userName = config.terra.userName;
    in
    lib.mkMerge [
      (lib.mkIf cfg.enable {
        users.users.${userName}.extraGroups = [ "transmission" ];
        systemd.tmpfiles.rules = [
          "L+ /home/${userName}/Downloads/transmission - - - - ${config.services.transmission.settings.download-dir}"
          "L+ /home/${userName}/Downloads/torrents - - - - ${config.services.transmission.settings.watch-dir}"
          "d /var/lib/peerbanhelper 0755 root root -"
        ];

        systemd.services.transmission.serviceConfig.StateDirectoryMode = "770";
        systemd.services.transmission-setup = {
          wantedBy = [ "transmission.service" ];
        };

        virtualisation.oci-containers.containers.peerbanhelper = {
          image = "docker.io/ghostchu/peerbanhelper:latest";
          autoStart = true;
          extraOptions = [
            "--network=host"
            "--label=io.containers.autoupdate=registry"
          ];
          volumes = [ "/var/lib/peerbanhelper:/app/data" ];
          environment.TZ = "Asia/Shanghai";
        };
      })

      (lib.mkIf (cfg.enable && cfg.rpc_secretFile != null) {
        age.secrets.transmission-rpc.file = config.terra.transmission.rpc_secretFile;
      })

      {
        services.transmission = {
          enable = cfg.enable;
          webHome = pkgs.flood-for-transmission;
          openPeerPorts = true;
          openRPCPort = true;
          downloadDirPermissions = "770";

          settings = {
            rpc-bind-address = "0.0.0.0";
            rpc-whitelist = "127.0.0.1,192.168.*.*";
            umask = "002";

            download-dir = "/home/${userName}/.transmission/downloads";
            incomplete-dir-enabled = true;
            incomplete-dir = "/home/${userName}/.transmission/.incomplete";
            watch-dir-enabled = true;
            watch-dir = "/home/${userName}/.transmission/watch";
            trash-original-torrent-files = true;

            speed-limit-up = cfg.speed.up;
            speed-limit-up-enabled = true;
            speed-limit-down = cfg.speed.down;
            speed-limit-down-enabled = true;

            alt-speed-up = cfg.alt-speed.up;
            alt-speed-down = cfg.alt-speed.down;
            alt-speed-enabled = false;

            rpc-authentication-required = cfg.rpc_secretFile != null;

            blocklist-enabled = true;
            blocklist-updates-enabled = true;
            blocklist-url = "https://raw.githubusercontent.com/PBH-BTN/BTN-Collected-Rules/master/combine/all.txt";
          };
        } // lib.optionalAttrs (cfg.enable && cfg.rpc_secretFile != null) {
          credentialsFile = config.age.secrets.transmission-rpc.path;
        };
      }
    ];
}
