{ config, lib, ... }:

{
  config = lib.mkMerge [
    {
      system.stateVersion = "25.11";
      nixpkgs.config.allowUnfree = true;

      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        extra-substituters = [
          "https://cache.nixos-cuda.org"
          "https://nix-community.cachix.org"
          "https://noctalia.cachix.org"
          "https://cache.numtide.com"
        ];
        extra-trusted-public-keys = [
          "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];
        auto-optimise-store = true;
        use-xdg-base-directories = true;
      };
    }
    (lib.mkIf config.terra.secrets.enable {
      age.secrets.nix-github-pat.file = ../secrets/nix-github-pat.age;

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
    })
  ];
}
