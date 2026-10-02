{ pkgs, ... }:

{
  imports = [
    ./monitors.nix
    ./appearance.nix
    ./input.nix
    ./binds.nix
    ./rules.nix
  ];

  services.gnome-keyring.enable = true;

  wayland.windowManager.niri = {
    enable = true;
    package = pkgs.niri;

    settings = {
      prefer-no-csd = { };
      hotkey-overlay.skip-at-startup = { };
      clipboard.disable-primary = { };
      screenshot-path = "~/Pictures/screenshots/screenshot_%Y-%m-%d/screenshot_%Y-%m-%d_%H-%M-%S.png";
      spawn-at-startup = [ "noctalia" ];
    };
  };
}
