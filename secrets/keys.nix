let
  nixos-pc-root    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAXJ13XhvC/sHitZzkd76pJvCdEyeorAoIUPUfjM7/bx root@nixos-pc";
  nixos-pc-dokee   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDLyvTIm73lhxrADGbrDQOUsaksrYL3RoV1v1gCHwkea dokee@nixos-pc-2026-03-23";
  arch-laptop-dokee = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzGZRZ7Wysqq+OBEgSi6EGZ2ZXGtFeCHYBfMnKXp8PJ dokee@arch-2025-05-26";
in {
  inherit nixos-pc-root nixos-pc-dokee arch-laptop-dokee;
  all = [ nixos-pc-root nixos-pc-dokee arch-laptop-dokee ];
}
