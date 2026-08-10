{ lib, modulesPath, pkgs, targetSystem, ... }:

let
  target = targetSystem.config.system.build.toplevel;
  installBootstrap = pkgs.writeShellApplication {
    name = "install-bootstrap";
    runtimeInputs = with pkgs; [
      coreutils
      nixos-install-tools
      util-linux
    ];
    text = ''
      targetSystem=${lib.escapeShellArg (toString target)}
    '' + builtins.readFile ../scripts/install-bootstrap;
  };
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix")
  ];

  system.installer.channel.enable = false;

  networking.networkmanager.wifi.backend = "iwd";

  environment.systemPackages = [
    installBootstrap
    pkgs.impala
  ];

  isoImage.storeContents = [ target ];
}
