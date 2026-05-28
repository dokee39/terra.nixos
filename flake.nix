{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien.url = "github:thiagokokada/nix-alien";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mmdb = {
      url = "github:alecthw/mmdb_china_ip_list?ref=release";
      flake = false;
    };

    lxgw-bright = {
      url = "github:lxgw/LxgwBright";
      flake = false;
    };
    awww = {
      url = "git+https://codeberg.org/LGFae/awww";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    orchis-kde = {
      url = "github:vinceliuice/Orchis-kde";
      flake = false;
    };
    mikan = {
      url = "https://github.com/iota9star/mikan_flutter/releases/latest/download/linux-release.zip";
      flake = false;
    };
    nautilus-image-converter = {
      url = "git+https://gitlab.gnome.org/coreyberla/nautilus-image-converter.git?ref=master";
      flake = false;
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/v5";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rose-pine-zellij = {
      url = "github:rose-pine/zellij";
      flake = false;
    };

    nixvim = {
      url = "github:nix-community/nixvim";
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
    blink-pairs = {
      url = "github:Saghen/blink.pairs?rev=2a7cb15f2c4bbbbe178ebf9f3fdae19aa6d28d39";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.astal.follows = "astal";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jina-reranker-v3 = {
      url = "https://huggingface.co/jinaai/jina-reranker-v3";
      type = "git";
      flake = false;
    };
  };

  outputs = inputs: {
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
        _module.args = { inherit inputs; };
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit inputs;
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
