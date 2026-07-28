{
  description = "Personal NixOS configuration";

  inputs = {
    # --- Core ---
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien.url = "github:thiagokokada/nix-alien";

    # --- Desktop / WM ---
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # --- Packages ---
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nautilus-image-converter = {
      url = "git+https://gitlab.gnome.org/coreyberla/nautilus-image-converter.git?ref=master";
      flake = false;
    };

    # --- Data / Theme ---
    mmdb = {
      url = "github:alecthw/mmdb_china_ip_list?ref=release";
      flake = false;
    };
    lxgw-bright = {
      url = "github:lxgw/LxgwBright";
      flake = false;
    };
    orchis-kde = {
      url = "github:vinceliuice/Orchis-kde";
      flake = false;
    };
    rose-pine-zellij = {
      url = "github:rose-pine/zellij";
      flake = false;
    };

    # --- Editor (nixvim) ---
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blink-lib = {
      url = "github:saghen/blink.lib?rev=b127d48bf8e9ac9cf41f6e0fbead317503f76558";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blink-cmp = {
      url = "github:Saghen/blink.cmp?rev=0f54bd78892f587db4dcf100a23eaddfc2a9df7d";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.blink-lib.follows = "blink-lib";
    };
    blink-pairs = {
      url = "github:Saghen/blink.pairs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.blink-lib.follows = "blink-lib";
    };
    beacon = {
      url = "github:DanilaMihailov/beacon.nvim";
      flake = false;
    };
    search-replace = {
      url = "github:roobert/search-replace.nvim";
      flake = false;
    };
    navbuddy = {
      url = "github:hasansujon786/nvim-navbuddy";
      flake = false;
    };
    im-select = {
      url = "github:keaising/im-select.nvim";
      flake = false;
    };
  };

  outputs = inputs: let
    fetchFlake = name: src: let
      srcPath = fetchTree {
        type = "github";
        owner = src.owner;
        repo = src.repo;
        rev = src.rev;
        narHash = src.hash;
      };
      raw = import (srcPath + "/flake.nix");
      resolvedInputs = builtins.mapAttrs
        (n: _: builtins.getAttr n inputs)
        raw.inputs;
    in raw.outputs (resolvedInputs // { self = fetchFlake name src; });

    sourcesRaw = builtins.fromJSON (builtins.readFile ./sources.json);
    sources = builtins.mapAttrs
      (name: src:
        if src.type == "flake"
        then fetchFlake name src
        else src)
      sourcesRaw;

    lib = inputs.nixpkgs.lib;
    hosts = builtins.attrNames (builtins.readDir ./hosts);
    mkHost = hostName: lib.nixosSystem {
      modules = [
        ./hosts/${hostName}
        { terra.hostName = hostName; }
        ./system
        inputs.agenix.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        ({ config, ... }: let
          pkgs-stable = import inputs.nixpkgs-stable {
            inherit (config.nixpkgs.hostPlatform) system;
            config.allowUnfree = true;
          };
        in {
          _module.args = {
            inherit inputs sources pkgs-stable;
            inherit (inputs) self;
          };
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit inputs sources pkgs-stable;
              inherit (inputs) self;
            };
            sharedModules = [
              inputs.agenix.homeManagerModules.default
            ];
            users.${config.terra.userName} = import ./home;
          };
        })
      ];
    };
  in {
    apps.x86_64-linux.install-minimal = let
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      installMinimal = pkgs.writeShellApplication {
        name = "install-minimal";
        runtimeInputs = with pkgs; [
          coreutils
          git
          gnused
          nix
          nixos-install-tools
          util-linux
        ];
        text = builtins.readFile ./scripts/install-minimal;
      };
    in {
      type = "app";
      program = "${installMinimal}/bin/install-minimal";
      meta.description = "Install a minimal Terra NixOS system";
    };

    nixosConfigurations = lib.genAttrs hosts mkHost;
  };
}
