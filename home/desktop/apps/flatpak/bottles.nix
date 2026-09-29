{ pkgs, sources, ... }:

let 
  appId = sources.bottles.appId;
  launcher = pkgs.writeShellApplication {
    name = "bottles";
    runtimeInputs = [ pkgs.flatpak ];
    text = ''
      flatpak run --user ${appId} "$@"
    '';
  };
in {
  home.packages = [ launcher ];

  services.flatpak.packages = [
    { inherit (sources.bottles) appId origin commit; }
  ];
}
