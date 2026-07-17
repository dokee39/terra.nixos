{ ... }: {
  imports = [ ./hardware.nix ];

  terra = {
    userName = "user_name";
    secrets.enable = false;
  };
}
