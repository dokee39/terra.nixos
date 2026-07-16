let keys = import ./keys.nix;
in {
  "mihomo-subscription-url.age".publicKeys = keys.all;
  "nix-github-pat.age".publicKeys = keys.all;
  "transmission-rpc.age".publicKeys = keys.all;
  "flood-env.age".publicKeys = keys.all;
}
