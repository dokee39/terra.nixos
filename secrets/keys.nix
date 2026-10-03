let
  nixos-pc-host      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBZzrQiKTNQYXGIkMi+fF2eia6iJO749JzcXGT9ZHYiJ root@nixos-pc";
  nixos-pc-dokee     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDjgapO4HPpL4Rzs8mmf9TRMO1J61LRUhp6nbAiL+zsX dokee@nixos-pc";
  nixos-laptop-host  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9svorJ1YHKyJIfhCCFGM4AL4IoQ+0wpm3A4G7QAI8c root@nixos-laptop";
  nixos-laptop-dokee = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdD850JuNPZySzeb0EAU+f95O6DBXmn7FTbi2PmxwJX dokee@nixos-laptop";
  nixos-mini-host    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKRH+r/7ARC4Qp8YG1aOlBWBugmKzo+nirMcG6U3GUmo root@nixos-mini";
  nixos-mini-dokee   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0COoAfLvIYLYuxqApvX0xCC6sQPdhuocv/LegMyEER dokee@nixos-mini";
  hosts = [
    nixos-pc-host
    nixos-laptop-host
    nixos-mini-host
  ];
  users = [
    nixos-pc-dokee
    nixos-laptop-dokee
    nixos-mini-dokee
  ];
in {
  inherit hosts users;
  all = hosts ++ users;
}
