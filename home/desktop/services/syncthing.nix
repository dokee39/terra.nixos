{ config, lib, osConfig, ... }:

let
  hostName = osConfig.terra.hostName;
  deviceIds = {
    nixos-pc = "J74FWWZ-TV4FWCN-X4FSE6P-2ZDHZJ7-EOSCXAA-2IPCET3-ZHGAXCU-JNY3DAT";
    nixos-laptop = "E7UZDS7-AHDIXR2-NCCGP3R-VHC3R5Z-XOSA7C3-7HMEJFE-GWW36UI-RLOSRAS";
  };
  peers = lib.filterAttrs
    (name: id: name != hostName && id != null)
    deviceIds;
in
{
  services.syncthing = lib.mkIf (builtins.hasAttr hostName deviceIds) {
    enable = true;

    settings = {
      devices = lib.mapAttrs (name: id: {
        inherit id;
        addresses = [
          "tcp://${name}:22000"
          "quic://${name}:22000"
        ];
      }) peers;

      options = {
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
      };

      folders.obsidian = {
        path = "${config.home.homeDirectory}/Documents/obsidian-repos/note";
        devices = builtins.attrNames peers;
        ignorePatterns = [ "/.obsidian/workspace.json" ];
      };
    };
  };
}
