{ lib, config, ... }:

let
  cfg = config.terra.gpu;
  gpu = cfg.internal;
in {
  options.terra = {
    gpu = {
      intelIgpu.enable = lib.mkEnableOption "Intel integrated GPU";

      nvidia = {
        enable = lib.mkEnableOption "NVIDIA GPU";

        prime = {
          intelBusId = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "PCI:0@0:2:0";
            description = "Intel iGPU PCI bus ID used for NVIDIA PRIME offload.";
          };

          nvidiaBusId = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "PCI:1@0:0:0";
            description = "NVIDIA GPU PCI bus ID used for NVIDIA PRIME offload.";
          };
        };
      };
    };

    gpu.internal = {
      enabled = lib.mkOption {
        type = lib.types.bool;
        readOnly = true;
        internal = true;
      };

      intelIgpuEnabled = lib.mkOption {
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
        enabled = cfg.intelIgpu.enable || cfg.nvidia.enable;
        intelIgpuEnabled = cfg.intelIgpu.enable;
        nvidiaEnabled = cfg.nvidia.enable;
        primeOffloadEnabled = cfg.intelIgpu.enable && cfg.nvidia.enable;
      };

      assertions = [
        {
          assertion = (!config.terra.desktop.enable) || cfg.internal.enabled;
          message = "A GPU must be enabled when terra.desktop.enable is true.";
        }
        {
          assertion = (!cfg.internal.primeOffloadEnabled) || (
            cfg.nvidia.prime.intelBusId != null && 
            cfg.nvidia.prime.nvidiaBusId != null
          );
          message = "Both PRIME bus IDs must be set when Intel iGPU and NVIDIA are enabled together.";
        }
      ];
    }

    (lib.mkIf gpu.enabled {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    })

    (lib.mkIf gpu.nvidiaEnabled {
      hardware.nvidia.open = true;
      hardware.nvidia.powerManagement.enable = true;
    })

    (lib.mkIf (gpu.nvidiaEnabled && !gpu.primeOffloadEnabled) {
      services.xserver.videoDrivers = [ "nvidia" ];
    })

    (lib.mkIf gpu.primeOffloadEnabled {
      services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

      hardware.nvidia.powerManagement.finegrained = true;
      hardware.nvidia.prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        intelBusId = cfg.nvidia.prime.intelBusId;
        nvidiaBusId = cfg.nvidia.prime.nvidiaBusId;
      };
    })
  ];
}
