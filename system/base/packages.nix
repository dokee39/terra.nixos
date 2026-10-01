{ pkgs, inputs, ... }:

{
  programs.fish.enable = true;
  programs.nix-ld.enable = true;
  security.polkit.enable = true;
  services.gvfs.enable = true;
  environment.wordlist.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    xh

    tree
    vim
    kitty.terminfo

    scowl

    bluetui

    p7zip
    _7zz-rar
    unar
    atool

    ffmpeg

    python3

    ripgrep
    jq
    yq-go
    fd
  ] ++ [
    inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}.nix-alien
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
