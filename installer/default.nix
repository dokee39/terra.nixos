{ inputs }:

let
  lib = inputs.nixpkgs.lib;

  mihomoModule = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.clashtui ];

    services.mihomo = {
      enable = true;
      configFile = "/var/lib/private/mihomo/config.yaml";
    };

    system.activationScripts.mihomo-mmdb.text = ''
      install -d -m 0755 /var/lib/private/mihomo
      install -m 0644 "${inputs.mmdb}/Country.mmdb" /var/lib/private/mihomo/Country.mmdb
    '';

    systemd.services.mihomo.unitConfig.ConditionPathExists =
      "/var/lib/private/mihomo/config.yaml";
  };

  targetSystem = lib.nixosSystem {
    modules = [
      { nixpkgs.hostPlatform = "x86_64-linux"; }
      ./target.nix
      mihomoModule
    ];
  };
in
lib.nixosSystem {
  specialArgs = { inherit targetSystem; };
  modules = [
    { nixpkgs.hostPlatform = "x86_64-linux"; }
    ./live.nix
    mihomoModule
  ];
}
