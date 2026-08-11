let
  nixos-pc-host      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAXJ13XhvC/sHitZzkd76pJvCdEyeorAoIUPUfjM7/bx root@nixos-pc";
  nixos-pc-dokee     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDLyvTIm73lhxrADGbrDQOUsaksrYL3RoV1v1gCHwkea dokee@nixos-pc";
  nixos-laptop-host  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9svorJ1YHKyJIfhCCFGM4AL4IoQ+0wpm3A4G7QAI8c root@nixos-laptop";
  nixos-laptop-dokee = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdD850JuNPZySzeb0EAU+f95O6DBXmn7FTbi2PmxwJX dokee@nixos-laptop";
  hosts = [ nixos-pc-host nixos-laptop-host ];
  users = [ nixos-pc-dokee nixos-laptop-dokee ];
in {
  inherit nixos-pc-host nixos-pc-dokee hosts users;
  all = hosts ++ users;
}
