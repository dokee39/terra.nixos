{ pkgs, lib, osConfig, ... }:

{
  imports = [
    ./shell
    ./env.nix
    ./btop.nix
    ./codex.nix
    ./yazi
    ./nvim
    ./dev.nix
    ./pi
  ] ++ lib.optionals osConfig.terra.desktop.enable [
    ./desktop
  ];

  home.stateVersion = "25.11";

  home.username = osConfig.terra.userName;
  home.homeDirectory = "/home/${osConfig.terra.userName}";

  xdg = {
    enable = true;
    localBinInPath = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
    };
  };
  home.preferXdgDirectories = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        addKeysToAgent = "yes";
        hashKnownHosts = true;
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "dokee";
      user.email = "dokee.39@gmail.com";
      init.defaultBranch = "main";
    };
  };
  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  services.udiskie.enable = true;

  home.packages = with pkgs; [
    hexyl
    glow

    nix-output-monitor

    tlrc
  ];

  services.tldr-update = {
    enable = true;
    package = pkgs.tlrc;
  };
}
