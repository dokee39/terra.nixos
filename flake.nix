{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
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
    noctalia.url = "github:noctalia-dev/noctalia";
    aegisub = {
      url = "github:arch1t3cht/Aegisub/migration03-02";
      flake = false;
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
      url = "github:Saghen/blink.pairs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    duckduckgo-mcp-server = {
      url = "github:nickclyde/duckduckgo-mcp-server";
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
        _module.args = {
          inherit inputs;
          inherit (inputs) self;
        };
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit inputs;
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
