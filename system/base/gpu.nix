{ lib, config, pkgs, ... }:

let
  cfg = config.terra.gpu;
  gpu = cfg.internal;
  igpuDriver = if cfg.igpu.vendor == "intel" then "modesetting" else "amdgpu";
in {
  options.terra = {
    gpu = {
      igpu = {
        enable = lib.mkEnableOption "integrated GPU";

        vendor = lib.mkOption {
          type = lib.types.nullOr (lib.types.enum [ "intel" "amd" ]);
          default = null;
          example = "intel";
          description = "Integrated GPU vendor.";
        };

        busId = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "PCI:0@0:2:0";
          description = "Integrated GPU PCI bus ID used for NVIDIA PRIME offload.";
        };
      };

      nvidia = {
        enable = lib.mkEnableOption "NVIDIA GPU";

        busId = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "PCI:1@0:0:0";
          description = "NVIDIA GPU PCI bus ID used for PRIME offload.";
        };
      };
    };

    gpu.internal = {
      enabled = lib.mkOption {
        type = lib.types.bool;
        readOnly = true;
        internal = true;
      };

      igpuEnabled = lib.mkOption {
        type = lib.types.bool;
        readOnly = true;
        internal = true;
      };

      nvidiaEnabled = lib.mkOption {
        type = lib.types.bool;
        readOnly = true;
        internal = true;
      };

      primeOffloadEnabled = lib.mkOption {
        type = lib.types.bool;
        readOnly = true;
        internal = true;
      };
    };
  };

  config = lib.mkMerge [
    {
      terra.gpu.internal = {
        enabled = cfg.igpu.enable || cfg.nvidia.enable;
        igpuEnabled = cfg.igpu.enable;
        nvidiaEnabled = cfg.nvidia.enable;
        primeOffloadEnabled = cfg.igpu.enable && cfg.nvidia.enable;
      };

      assertions = [
        {
          assertion = (!config.terra.desktop.enable) || gpu.enabled;
          message = "A GPU must be enabled when terra.desktop.enable is true.";
        }
        {
          assertion = (!gpu.igpuEnabled) || cfg.igpu.vendor != null;
          message = "An iGPU vendor must be set when the integrated GPU is enabled.";
        }
        {
          assertion = (!gpu.primeOffloadEnabled) || (
            cfg.igpu.busId != null &&
            cfg.nvidia.busId != null
          );
          message = "Both GPU bus IDs must be set when the iGPU and NVIDIA GPU are enabled together.";
        }
      ];
    }

    (lib.mkIf gpu.enabled {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    })

    (lib.mkIf (gpu.igpuEnabled && cfg.igpu.vendor == "intel") {
      hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];
    })

    (lib.mkIf gpu.nvidiaEnabled {
      hardware.nvidia.open = true;
      hardware.nvidia.powerManagement.enable = true;
    })

    (lib.mkIf (gpu.nvidiaEnabled && !gpu.primeOffloadEnabled) {
      services.xserver.videoDrivers = [ "nvidia" ];
    })

    (lib.mkIf gpu.primeOffloadEnabled {
      services.xserver.videoDrivers = [ igpuDriver "nvidia" ];

      hardware.nvidia.powerManagement.finegrained = true;
      hardware.nvidia.prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        nvidiaBusId = cfg.nvidia.busId;
      } // lib.optionalAttrs (cfg.igpu.vendor == "intel") {
        intelBusId = cfg.igpu.busId;
      } // lib.optionalAttrs (cfg.igpu.vendor == "amd") {
        amdgpuBusId = cfg.igpu.busId;
      };
    })
  ];
}
