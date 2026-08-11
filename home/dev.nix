{ pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;

    stdlib = ''
      use_devflake() {
        use flake "$@"

        local name=''${1##*#}

        if [ -z "$1" ] || [ "$name" = "$1" ]; then
          name=default
        fi

        export DEVSHELL_NAME=$name
      }
    '';
  };

  home.packages = with pkgs; [
    pkg-config

    gh

    tokei

    # C/C++
    clang
    clang-tools
    gnumake
    cmake
    bear

    # Rust
    cargo
    rustc
    rustfmt
    clippy
    rust-analyzer

    # Lua
    lua5_4
  ];
}
