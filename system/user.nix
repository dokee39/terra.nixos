{ config, pkgs, inputs, ... }:

{
  users.users.${config.terra.userName} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "storage"
      "power"
      "audio"
      "video"
      "uucp"
      "input"
      "i2c"
    ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = config.terra.authorizedSshKeys;
  };

  console = {
    earlySetup = true;
    colors = [
      "393552"  # 0  Black   → Overlay
      "eb6f92"  # 1  Red     → Love
      "9ccfd8"  # 2  Green   → Foam
      "f6c177"  # 3  Yellow  → Gold
      "3e8fb0"  # 4  Blue    → Pine
      "c4a7e7"  # 5  Magenta → Iris
      "ea9a97"  # 6  Cyan    → Rose
      "e0def4"  # 7  White   → Text
      "5c5776"  # 8  Bright Black  → lighter Overlay
      "ff98ba"  # 9  Bright Red    → lighter Love
      "c5f9ff"  # 10 Bright Green  → lighter Foam
      "ffeb9e"  # 11 Bright Yellow → lighter Gold
      "6ab7d9"  # 12 Bright Blue   → lighter Pine
      "eed0ff"  # 13 Bright Magenta→ lighter Iris
      "ffc3bf"  # 14 Bright Cyan   → lighter Rose
      "fefcff"  # 15 Bright White  → lighter Text
    ];
  };

  programs.fish.enable = true;
  programs.nix-ld.enable = true;

  hardware.enableRedistributableFirmware = true;
  hardware.i2c.enable = true;

  hardware.bluetooth.enable = true;
  hardware.xpadneo = {
    enable = true;
    settings.disabled_deadzones = 1;
  };
  hardware.bluetooth.settings = {
    LE = {
      MinConnectionInterval = 7;
      MaxConnectionInterval = 9;
      ConnectionLatency = 0;
    };
  };

  services.gvfs.enable = true;
  services.udisks2 = {
    enable = true;
    settings."mount_options.conf" = {
      defaults = {
        "ntfs:ntfs3_defaults" =
          "uid=$UID,gid=$GID,fmask=0133,dmask=0022,windows_names,prealloc,force";
        "ntfs:ntfs3_allow" =
          "uid=$UID,gid=$GID,umask,dmask,fmask,iocharset,discard,nodiscard,sparse,nosparse,hidden,nohidden,sys_immutable,nosys_immutable,showmeta,noshowmeta,prealloc,noprealloc,hide_dot_files,nohide_dot_files,windows_names,nocase,case,force";
        ntfs_drivers = "ntfs3";
      };
    };
  };

  security.polkit.enable = true;

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

  environment.wordlist.enable = true;
}
