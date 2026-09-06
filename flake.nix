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
    colloid-kde = {
      url = "github:vinceliuice/Colloid-kde";
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
      url = "github:saghen/blink.lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blink-cmp = {
      url = "github:Saghen/blink.cmp";
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
    lib = inputs.nixpkgs.lib;
    system = "x86_64-linux";

    sources = builtins.fromJSON (builtins.readFile ./sources.json);
    mkHost = import ./hosts { inherit inputs sources; };
    hostNames = builtins.attrNames (
      lib.filterAttrs
        (_: type: type == "directory")
        (builtins.readDir ./hosts)
    );

    installerSystem = import ./installer { inherit inputs; };
  in {
    nixosConfigurations = lib.genAttrs hostNames mkHost;

    packages.${system}.installer-iso =
      installerSystem.config.system.build.isoImage;
  };
}
