{ config, desktopContext ? {}, lib, pkgs, sloth, ... }:

let
  inherit (config.flatpak) appId;
  nvidiaEnabled = lib.attrByPath [ "nvidiaEnabled" ] false desktopContext;
in
{
  config = {
    dbus = {
      policies =
        {
          "${appId}" = "own";
          "${appId}.*" = "own";

          "org.freedesktop.DBus" = "talk";
          "ca.desrt.dconf" = "talk";
          "org.freedesktop.appearance" = "talk";
          "org.freedesktop.appearance.*" = "talk";
        }
        // {
          "com.canonical.AppMenu.Registrar" = "talk";
          "org.freedesktop.FileManager1" = "talk";
          "org.freedesktop.Notifications" = "talk";

          "org.a11y.Bus" = "see";

          "org.freedesktop.portal.Documents" = "talk";
          "org.freedesktop.portal.FileTransfer" = "talk";
          "org.freedesktop.portal.FileTransfer.*" = "talk";
          "org.freedesktop.portal.Notification" = "talk";
          "org.freedesktop.portal.OpenURI" = "talk";
          "org.freedesktop.portal.OpenURI.OpenFile" = "talk";
          "org.freedesktop.portal.OpenURI.OpenURI" = "talk";
          "org.freedesktop.portal.Request" = "see";
          "org.freedesktop.portal.Fcitx" = "talk";
          "org.freedesktop.portal.Fcitx.*" = "talk";
          "org.freedesktop.portal.IBus" = "talk";
          "org.freedesktop.portal.IBus.*" = "talk";
        };

      rules.call = {
        "org.a11y.Bus" = [
          "org.a11y.Bus.GetAddress@/org/a11y/bus"
          "org.freedesktop.DBus.Properties.Get@/org/a11y/bus"
        ];

        "org.freedesktop.FileManager1" = [ "*" ];
        "org.freedesktop.Notifications.*" = [ "*" ];

        "org.freedesktop.portal.Documents" = [ "*" ];
        "org.freedesktop.portal.FileTransfer" = [ "*" ];
        "org.freedesktop.portal.FileTransfer.*" = [ "*" ];
        "org.freedesktop.portal.Fcitx" = [ "*" ];
        "org.freedesktop.portal.Fcitx.*" = [ "*" ];
        "org.freedesktop.portal.IBus" = [ "*" ];
        "org.freedesktop.portal.IBus.*" = [ "*" ];
        "org.freedesktop.portal.Notification" = [ "*" ];
        "org.freedesktop.portal.OpenURI" = [ "*" ];
        "org.freedesktop.portal.OpenURI.OpenFile" = [ "*" ];
        "org.freedesktop.portal.OpenURI.OpenURI" = [ "*" ];
        "org.freedesktop.portal.Request" = [ "*" ];

        "org.freedesktop.portal.Desktop" = [
          "org.freedesktop.DBus.Properties.GetAll"
          "org.freedesktop.DBus.Properties.Get@/org/freedesktop/portal/desktop"
          "org.freedesktop.portal.Session.Close"
          "org.freedesktop.portal.Settings.ReadAll"
          "org.freedesktop.portal.Settings.Read"
          "org.freedesktop.portal.Account.GetUserInformation"

          "org.freedesktop.portal.NetworkMonitor"
          "org.freedesktop.portal.NetworkMonitor.*"
          "org.freedesktop.portal.ProxyResolver.Lookup"
          "org.freedesktop.portal.ProxyResolver.Lookup.*"

          "org.freedesktop.portal.Documents"
          "org.freedesktop.portal.Documents.*"
          "org.freedesktop.portal.FileChooser"
          "org.freedesktop.portal.FileChooser.*"
          "org.freedesktop.portal.FileTransfer"
          "org.freedesktop.portal.FileTransfer.*"

          "org.freedesktop.portal.Notification"
          "org.freedesktop.portal.Notification.*"

          "org.freedesktop.portal.OpenURI"
          "org.freedesktop.portal.OpenURI.*"

          "org.freedesktop.portal.Fcitx"
          "org.freedesktop.portal.Fcitx.*"
          "org.freedesktop.portal.IBus"
          "org.freedesktop.portal.IBus.*"

          "org.freedesktop.portal.Request"
        ];
      };

      rules.broadcast = {
        "org.freedesktop.portal.*" = [ "@/org/freedesktop/portal/*" ];
      };

      args = [
        "--filter"
        "--sloppy-names"
      ];
    };

    gpu = {
      enable = lib.mkDefault true;
      provider = "nixos";
      bundlePackage = pkgs.mesa.drivers;
    };

    bubblewrap = {
      bind.rw = with sloth; [
        (sloth.concat' runtimeDir "/at-spi/bus")
        (sloth.concat' runtimeDir "/dconf")
        (sloth.concat' runtimeDir "/doc")
      ];

      bind.ro = with sloth; [
        (sloth.concat' xdgConfigHome "/kdeglobals")
        (sloth.concat' xdgConfigHome "/gtk-2.0")
        (sloth.concat' xdgConfigHome "/gtk-3.0")
        (sloth.concat' xdgConfigHome "/gtk-4.0")
        (sloth.concat' xdgConfigHome "/fontconfig")
        (sloth.concat' xdgConfigHome "/dconf")
        (sloth.concat' xdgDataHome "/icons")
        (sloth.concat' xdgDataHome "/themes")
        "/run/current-system/sw/share/icons"
        "/run/current-system/sw/share/themes"
        "/etc/fonts"
        "/etc/localtime"
        "/etc/zoneinfo"
        "/etc/egl"
        "/etc/static/egl"
      ];

      bind.dev = lib.optionals nvidiaEnabled [
        "/dev/nvidia0"
        "/dev/nvidiactl"
        "/dev/nvidia-modeset"
        "/dev/nvidia-uvm"
      ];

      tmpfs = lib.optionals (!config.bubblewrap.sockets.x11) [
        "/tmp"
      ];

      sockets = {
        x11 = lib.mkDefault false;
        wayland = lib.mkDefault true;
      };
    };
  };
}
