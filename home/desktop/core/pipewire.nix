{ ... }:

{
  services.pipewire = {
    enable = true;
    wireplumber = {
      enable = true;
      configs."51-volume-fix"."monitor.alsa.rules" = [
        {
          matches = [
            { "device.name" = "~alsa_card.*"; }
          ];
          actions."update-props" = {
            "api.alsa.soft-mixer" = true;
          };
        }
      ];
    };
  };
}
