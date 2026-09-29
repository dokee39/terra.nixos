{ config, ... }:

{
  system.stateVersion = "25.11";
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      "https://cache.nixos-cuda.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    auto-optimise-store = true;
    use-xdg-base-directories = true;
  };

  age.secrets.nix-github-pat = {
    file = ../secrets/nix-github-pat.age;
    owner = config.terra.userName;
    mode = "0400";
  };

  nix.extraOptions = ''
    !include ${config.age.secrets.nix-github-pat.path}
  '';
}
