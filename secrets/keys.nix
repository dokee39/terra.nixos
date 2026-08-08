let
  nixos-pc-host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAXJ13XhvC/sHitZzkd76pJvCdEyeorAoIUPUfjM7/bx root@nixos-pc";
  nixos-pc-dokee = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDLyvTIm73lhxrADGbrDQOUsaksrYL3RoV1v1gCHwkea dokee@nixos-pc-2026-03-23";
  hosts = [ nixos-pc-host ];
  users = [ nixos-pc-dokee ];
in {
  inherit nixos-pc-host nixos-pc-dokee hosts users;
  all = hosts ++ users;
}
