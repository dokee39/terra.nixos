{ inputs }:

let
  fetchFlake = name: src:
    let
      srcPath = fetchTree {
        type = "github";
        owner = src.owner;
        repo = src.repo;
        rev = src.rev;
        narHash = src.hash;
      };
      raw = import (srcPath + "/flake.nix");
      resolvedInputs = builtins.mapAttrs (n: _: builtins.getAttr n inputs) raw.inputs;
    in
    raw.outputs (resolvedInputs // { self = fetchFlake name src; });

  sourcesRaw = builtins.fromJSON (builtins.readFile ./sources.json);
in
builtins.mapAttrs (
  name: src:
  if src.type == "flake" then fetchFlake name src else src
) sourcesRaw
