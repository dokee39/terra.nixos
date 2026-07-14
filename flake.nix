{
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
    blink-pairs = {
      url = "github:Saghen/blink.pairs";
      inputs.nixpkgs.follows = "nixpkgs";
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

    # --- AI / Pi ---
  };

  outputs = inputs: let
    fetchFlake = name: src: let
      srcPath = builtins.fetchTree {
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
  in {
    templates.default = {
      path = ./templates;
      description = "flake.nix for new computers";
      welcomeText = ''
        Welcome to NixOS!
      '';
    };
    terraModules.default = { config, ... }: {
      imports = [
        ./system
        ./terra.nix
        inputs.agenix.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
      ];

      config = {
        _module.args = {
          inherit inputs sources;
          inherit (inputs) self;
        };
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit inputs sources;
            inherit (inputs) self;
            pkgs-stable = import inputs.nixpkgs-stable {
              inherit (config.nixpkgs.hostPlatform) system;
              config.allowUnfree = true;
            };
          };
          sharedModules = [
            inputs.agenix.homeManagerModules.default
          ];
          users.${config.terra.userName} = import ./home;
        };
      };
    };
  };
}
