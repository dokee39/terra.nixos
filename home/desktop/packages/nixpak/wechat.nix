{
  lib,
  pkgs,
  mkNixPak,
  buildEnv,
  makeDesktopItem,
  writeShellApplication,
  coreutils,
  desktopContext ? {},
  ...
}:

let
  appId = "com.tencent.WeChat";
  wechatScaleFactor = lib.attrByPath [ "wechatScaleFactor" ] null desktopContext;

  wechatAppImageTools = let
    base = pkgs.appimageTools;
  in base // {
    wrapAppImage =
      args:
      base.wrapAppImage (
        args // {
          extraPkgs = pkgs':
            (args.extraPkgs or (_: [ ])) pkgs'
            ++ [
              (lib.hiPrio pkgs'.flatpak-xdg-utils)
            ];
        }
      );
  };

  wechatScope = lib.makeScope pkgs.newScope (_: {
    appimageTools = wechatAppImageTools;
  });
  wechatPackage = (wechatScope.callPackage "${pkgs.path}/pkgs/by-name/we/wechat/package.nix" { }).overrideAttrs (old: {
    buildCommand = builtins.replaceStrings
      ["--replace-fail AppRun wechat"]
      ["--replace-quiet AppRun wechat"]
      old.buildCommand;
  });

  wrapped = mkNixPak {
    config = { sloth, ... }:
      let
        hostHome = sloth.homeDir;
        hostAppDir = sloth.concat' hostHome "/.var/app/${appId}";
        hostAppDataDir = sloth.concat' hostAppDir "/data";
      in
      {
        _module.args = {
          inherit desktopContext;
        };

        app = {
          package = wechatPackage;
          binPath = "bin/wechat";
        };

        flatpak.appId = appId;

        imports = [
          ./modules/sandbox-base.nix
          ./modules/desktop-integration.nix
          ./modules/capabilities.nix
        ];

        sandbox.capabilities = {
          network.enable = true;
          tray.enable = true;
          audio.enable = true;
          camera.enable = true;
          downloads = "rw";
          pictures = "rw";
        };

        bubblewrap = {
          dieWithParent = true;
          newSession = true;

          env = {
            HOME = hostHome;
            QT_QPA_PLATFORM = "xcb";
          }
          // (
            if wechatScaleFactor == null then
              { QT_AUTO_SCREEN_SCALE_FACTOR = "1"; }
            else
              { QT_SCALE_FACTOR = toString wechatScaleFactor; }
          );

          bind.rw = [
            [ (sloth.mkdir (sloth.concat' hostAppDataDir "/.xwechat")) (sloth.concat' hostHome "/.xwechat") ]
            [ (sloth.mkdir (sloth.concat' hostAppDataDir "/xwechat_files")) (sloth.concat' hostHome "/xwechat_files") ]
          ];

          bind.ro = [
            "/etc/machine-id"
          ];

          sockets = {
            x11 = true;
            wayland = false;
          };
        };
      };
  };

  launcher = writeShellApplication {
    name = "wechat";

    runtimeInputs = [
      coreutils
    ];

    text = ''
      set -eu

      host_home="$HOME"
      legacy_home_dir="$host_home/Documents/WeChat_Data/home"
      host_app_dir="$host_home/.var/app/${appId}"
      host_app_data_dir="$host_app_dir/data"

      migrate_path_once() {
        local src="$1"
        local dst="$2"

        if [ -e "$src" ] && [ ! -e "$dst" ]; then
          mkdir -p "$(dirname "$dst")"
          mv "$src" "$dst"
        fi

        mkdir -p "$dst"
      }

      mkdir -p \
        "$host_app_dir"

      migrate_path_once "$legacy_home_dir/.config" "$host_app_dir/config"
      migrate_path_once "$legacy_home_dir/.cache" "$host_app_dir/cache"
      migrate_path_once "$legacy_home_dir/.local/share" "$host_app_dir/data"
      migrate_path_once "$legacy_home_dir/.xwechat" "$host_app_data_dir/.xwechat"
      migrate_path_once "$legacy_home_dir/xwechat_files" "$host_app_data_dir/xwechat_files"

      if [ -n "''${XAUTHORITY:-}" ] && [ -e "$XAUTHORITY" ]; then
        :
      else
        export XAUTHORITY="$host_home/.Xauthority"
      fi

      unset WAYLAND_DISPLAY

      exec ${lib.getExe wrapped.config.script} \
        --no-sandbox \
        "$@"
    '';
  };

  exePath = lib.getExe launcher;
in
  buildEnv {
    inherit (wrapped.config.script) name meta passthru;

    paths = [
      launcher

      (makeDesktopItem {
        name = appId;
        desktopName = "WeChat";
        genericName = "WeChat Boxed";
        comment = "Tencent WeChat sandboxed with nixpak";
        exec = "${exePath} %U";
        terminal = false;
        icon = "${wechatPackage}/share/icons/hicolor/256x256/apps/wechat.png";
        startupNotify = true;
        type = "Application";
        categories = [ "InstantMessaging" "Network" ];
        extraConfig = {
          X-Flatpak = appId;
        };
      })
    ];
  }
