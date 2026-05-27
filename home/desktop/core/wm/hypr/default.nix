{ ... }:

{
  imports = [
    ./monitors.nix
    ./appearance.nix
    ./input.nix
    ./binds.nix
    ./rules.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    package = null;
    portalPackage = null;

    configType = "hyprlang";
  };

  wayland.windowManager.hyprland.settings = {
    ecosystem = {
      no_update_news = true;
      no_donation_nag = true;
      enforce_permissions = false;
    };
  };
}
