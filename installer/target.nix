{ modulesPath, pkgs, ... }:

{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
    ../system/network/common.nix
  ];

  system.stateVersion = "25.11";

  hardware.enableAllHardware = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos-root";
      fsType = "ext4";
    };
    "/home" = {
      device = "/dev/disk/by-label/nixos-home";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };

  networking.hostName = "";

  services.openssh.settings.PasswordAuthentication = true;

  systemd.services.mihomo.unitConfig.ConditionPathExists =
    "/var/lib/private/mihomo/config.yaml";

  environment.systemPackages = with pkgs; [
    git
    neovim
  ];
  environment.sessionVariables.EDITOR = "nvim";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
