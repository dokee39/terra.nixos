{ config, pkgs, lib, ... }:

{
  imports = [
    ./fonts.nix
    ./network.nix
    ./mihomo.nix
    ./desktop.nix
    ./user.nix
    ./maintenance.nix
    ./gpu.nix
    ./ram.nix
    ./steam.nix
    ./transmission.nix
    ./ai
    ./virtualisation.nix
  ];

  system.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [ 
      "https://cache.nixos-cuda.org"
      "https://nix-community.cachix.org"
      "https://noctalia.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
    auto-optimise-store = true;
    use-xdg-base-directories = true;
  };

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_GB.UTF-8";

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = lib.mkDefault 1;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };

  age.secrets.nix-github-pat.file = config.terra.nix.githubPat_secretFile;
  nix.extraOptions = ''
    !include /run/nix/access-tokens.conf
  '';
  system.activationScripts.nixAccessTokens = {
    deps = [ "agenix" ];
    text = ''
      install -d -m 0755 /run/nix
      umask 177
      token="$(tr -d '\r\n' < ${config.age.secrets.nix-github-pat.path})"
      printf 'access-tokens = github.com=%s\n' "$token" > /run/nix/access-tokens.conf
      chmod 644 /run/nix/access-tokens.conf
    '';
  };
}
