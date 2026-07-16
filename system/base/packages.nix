{ pkgs, inputs, config, ... }:

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
    inputs.nix-alien.packages.${config.terra.system}.nix-alien
    inputs.agenix.packages.${config.terra.system}.default
  ];
}
