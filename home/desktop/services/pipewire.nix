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
            # HACK: Hardware volume control silences the built-in speakers at low levels.
            "api.alsa.soft-mixer" = true;
          };
        }
      ];
    };
  };
}
