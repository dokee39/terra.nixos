{ ... }:

{
  imports = [
    ./maintenance.nix
    ./gpu.nix
    ./ram.nix
    ./hardware.nix
    ./boot.nix
    ./fonts.nix
    ./packages.nix
  ];
}
