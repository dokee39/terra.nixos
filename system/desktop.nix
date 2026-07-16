{ config, pkgs, lib, ... }:

let
  cfg = config.terra.desktop;
in {
  options.terra.desktop = {
    enable = lib.mkEnableOption "desktop environment";

    monitors = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          primary = lib.mkEnableOption "primary monitor";

          mode = lib.mkOption {
            type = lib.types.nullOr (lib.types.submodule {
              options = {
                width = lib.mkOption { type = lib.types.int; };
                height = lib.mkOption { type = lib.types.int; };
                refresh = lib.mkOption {
                  type = lib.types.nullOr lib.types.number;
                  default = null;
                };
              };
            });
            default = null;
            description = "Resolution and optional refresh. null = compositor auto-detect.";
          };

          position = lib.mkOption {
            type = lib.types.nullOr (lib.types.submodule {
              options = {
                x = lib.mkOption { type = lib.types.int; };
                y = lib.mkOption { type = lib.types.int; };
              };
            });
            default = null;
            description = "Monitor position { x, y } in logical pixels. null = auto.";
          };

          scale = lib.mkOption {
            type = lib.types.number;
            default = 1;
            description = "Scale factor.";
          };

          transform = lib.mkOption {
            type = lib.types.submodule {
              options = {
                rotation = lib.mkOption {
                  type = lib.types.enum [ 0 90 180 270 ];
                  default = 0;
                };
                flipped = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                };
              };
            };
            default = { };
            description = "Output rotation and flip.";
          };
        };
      });
      default = { };
    };

    primaryMonitor = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      readOnly = true;
      internal = true;
      default = lib.findFirst
      (name: cfg.monitors.${name}.primary)
      null
      (builtins.attrNames cfg.monitors);
    };
  };

  config = {
    assertions = [
      {
        assertion =
          !cfg.enable
          || builtins.length (builtins.filter
            (name: cfg.monitors.${name}.primary)
            (builtins.attrNames cfg.monitors)) == 1;
        message = "terra.desktop.monitors must have exactly one primary monitor";
      }
    ];
  } // lib.mkIf cfg.enable {
    services.displayManager.sessionPackages = [ pkgs.niri ];
    services.displayManager.ly = {
      enable = true;
      x11Support = false;
      settings = {
        full_color                  = false;
        bg                          = "0x0001";
        fg                          = "0x0008";
        border_fg                   = "0x0006";
        error_bg                    = "0x0000";
        error_fg                    = "0x0102";
        blank_box                   = true;
                                    
        cmatrix_fg                  = "0x0003";
        cmatrix_head_col            = "0x0108";
                                    
        colormix_col1               = "0x0002";
        colormix_col2               = "0x0005";
        colormix_col3               = "0x0001";

        gameoflife_fg               = "0x0003";
        gameoflife_initial_density  = 0.4;
        gameoflife_entropy_interval = 10;
        gameoflife_frame_delay      = 6;

        doom_fire_height            = 6;
        doom_fire_spread            = 2;
        doom_top_color              = "0x0007";
        doom_middle_color           = "0x0002";
        doom_bottom_color           = "0x0004";

        animation                   = "doom";
        animation_frame_delay       = 20;

        clock                       = "%c";
        bigclock                    = "en";

        shell                       = false;
        auth_fails                  = 3;
        numlock                     = true;
        session_log                 = ".local/state/ly-session.log";

        shutdown_cmd                = "systemctl poweroff";
        restart_cmd                 = "systemctl reboot";
        sleep_cmd                   = "systemctl suspend-then-hibernate";
        hibernate_cmd               = "systemctl hibernate";
      };
    };

    xdg.portal = {
      enable = lib.mkForce true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      config = {
        common.default = [ "gtk" "gnome" ];
      };
    };

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    services.dbus.implementation = "broker";

    programs.dconf.enable = true;
    security.rtkit.enable = true;
  };
}
