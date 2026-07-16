{ config, pkgs, lib, ... }:

let
  cfg = config.terra.boot;
in {
  options.terra.boot = {
    grubTimeOut = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = 1;
    };
  };

  config = {
    boot.kernelPackages = pkgs.linuxPackages_latest;

    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.timeout = cfg.grubTimeOut;
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
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
  };
}
