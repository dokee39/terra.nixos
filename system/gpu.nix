{ lib, config, ... }:

let
  gpu = config.terra._internal.gpu;
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

    _internal.gpu = {
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
      terra._internal.gpu = {
        enabled =
          config.terra.gpu.intelIgpu.enable
          || config.terra.gpu.nvidia.enable;

        intelIgpuEnabled = config.terra.gpu.intelIgpu.enable;
        nvidiaEnabled = config.terra.gpu.nvidia.enable;

        primeOffloadEnabled =
          config.terra.gpu.intelIgpu.enable
          && config.terra.gpu.nvidia.enable;
      };

      assertions = [
        {
          assertion =
            (!config.terra.desktop.enable)
            || config.terra._internal.gpu.enabled;
          message = "A GPU must be enabled when terra.desktop.enable is true.";
        }
        {
          assertion =
            (!config.terra._internal.gpu.primeOffloadEnabled)
            || (
              config.terra.gpu.nvidia.prime.intelBusId != null
              && config.terra.gpu.nvidia.prime.nvidiaBusId != null
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
        intelBusId = config.terra.gpu.nvidia.prime.intelBusId;
        nvidiaBusId = config.terra.gpu.nvidia.prime.nvidiaBusId;
      };
    })
  ];
}
