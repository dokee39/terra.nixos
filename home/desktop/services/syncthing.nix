{ config, lib, osConfig, ... }:

let
  hostName = osConfig.terra.hostName;
  deviceIds = {
    nixos-pc = "5XIVPM5-HURUR4F-OPDEXMD-M6BL5TG-7YRUWIJ-7AF7IEL-D5KHMGA-NTY5KAD";
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
      devices = lib.mapAttrs (_: id: { inherit id; }) peers;

      folders.obsidian = {
        path = "${config.home.homeDirectory}/Documents/obsidian-repos/note";
        devices = builtins.attrNames peers;
        ignorePatterns = [ "/.obsidian/workspace.json" ];
      };
    };
  };
}
