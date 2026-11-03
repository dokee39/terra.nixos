{ config, inputs, lib, pkgs, ... }:

let
  appIds = map (package: package.appId) config.services.flatpak.packages;
  systemctl = "${config.systemd.user.systemctlPath} --user";
in
{
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    ./bottles.nix
    ./qq.nix
    ./wechat.nix
  ];

  services.flatpak.restartOnFailure = {
    enable = true;
    restartDelay = "30s";
  };

  systemd.user.services.flatpak-managed-install = {
    Install.WantedBy = lib.mkForce [ ];
    Unit = {
      After = lib.mkForce [ ];
      # Let the activation hook handle restarts without blocking Home Manager.
      X-SwitchMethod = "keep-old";
      StartLimitIntervalSec = "infinity";
      StartLimitBurst = 3;
      OnFailure = [ "flatpak-managed-install-failed.service" ];
    };
    # Skip failure notifications during automatic retries.
    Service.RestartMode = "direct";
  };

  # HACK: nix-flatpak blocks activation on downloads; schedule synchronization asynchronously.
  home.activation.flatpak-managed-install = lib.mkForce (lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
    if ${config.systemd.user.systemctlPath} is-system-running -q; then
      # A glob allows reset-failed to succeed when the unit is not loaded.
      run ${systemctl} reset-failed 'flatpak-managed-install.*' &&
        run ${systemctl} restart --no-block flatpak-managed-install.service ||
        warnEcho "Failed to schedule Flatpak sync. Check the user systemd journal."
    fi
  '');

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
