{ config, inputs, lib, pkgs, ... }:

let
  appIds = map (package: package.appId) config.services.flatpak.packages;
in
{
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    ./qq.nix
    ./wechat.nix
  ];

  services.flatpak.restartOnFailure.enable = false;

  systemd.user.services.flatpak-managed-install = {
    Install.WantedBy = lib.mkForce [ ];
    Unit.OnFailure = [ "flatpak-managed-install-failed.service" ];
  };

  # HACK: nix-flatpak's Home Manager activation hides installation failures.
  systemd.user.services.flatpak-managed-install-failed = {
    Unit.Description = "Notify about failed Flatpak synchronization";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.libnotify}/bin/notify-send -u critical 'Flatpak sync failed' 'Check the user journal for flatpak-managed-install.service'";
    };
  };

  # HACK: sandbox XDG_CONFIG_HOME fontconfig is empty, dropping host fontconfig rules.
  # Delete stale app conf.d files manually when host rules are removed or renamed.
  home.activation.flatpak-fontconfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    for app in ${lib.concatStringsSep " " appIds}; do
      dst="$HOME/.var/app/$app/config/fontconfig/conf.d"
      $DRY_RUN_CMD install -d "$dst"
      $DRY_RUN_CMD cp -fL "$HOME"/.config/fontconfig/conf.d/*.conf "$dst"
    done
  '';
}
