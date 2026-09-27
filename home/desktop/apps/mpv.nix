{ pkgs, config, lib, osConfig, ... }:

let
  gpu = osConfig.terra.gpu;
  igpuVendor = if gpu.igpu.vendor == "intel" then "*intel*" else "*radeon*";
  powerAware = osConfig.terra.hardware.hasBattery && gpu.internal.primeOffloadEnabled;
  mpvBin = lib.getExe config.programs.mpv.finalPackage;
in {
  home.packages = lib.optionals powerAware [
    (lib.hiPrio (pkgs.writeShellScriptBin "mpv" ''
      if [[ $(busctl get-property org.freedesktop.UPower \
        /org/freedesktop/UPower org.freedesktop.UPower OnBattery) == "b false" ]]; then
        export VK_LOADER_DRIVERS_SELECT='*nvidia*'
        exec nvidia-offload ${mpvBin} --hwdec=nvdec-copy --profile=high-quality "$@"
      fi

      export VK_LOADER_DRIVERS_SELECT='${igpuVendor}'
      exec ${mpvBin} "$@"
    ''))
  ];

  programs.mpv = {
    enable = true;
    extraMakeWrapperArgs = lib.optionals gpu.internal.igpuEnabled [
      "--set-default"
      "VK_LOADER_DRIVERS_SELECT"
      igpuVendor
    ];
    scripts = with pkgs.mpvScripts; [
      uosc
      thumbfast
      mpris
    ];
    defaultProfiles = lib.optionals (!powerAware) [ "high-quality" ];
    config = {
      gpu-api = "vulkan";
      hwdec = if gpu.internal.igpuEnabled then "vaapi" else "nvdec-copy";

      screenshot-directory = "~/Downloads";
      screenshot-template = "%F-%{estimated-frame-number:%P}";
      screenshot-format = "png";

      save-position-on-quit = true;
      keep-open = true;

      osd-bar = false;
      osd-fractions = true;
      border = false;
      osc = false;

      sub-auto = "fuzzy";
      sub-file-paths = "sub:subs:subtitle:subtitles";
      sub-ass-override = "no";
      sub-fonts-dir = "Fonts";

      cscale = "catmull_rom";
      deband = true;
      icc-profile-auto = true;
      blend-subtitles = "video";
      video-sync = "display-resample";
      interpolation = true;
    };
  };

  xdg.configFile."mpv/fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <include ignore_missing="yes">/etc/fonts/fonts.conf</include>
      <dir>${config.home.homeDirectory}/.local/share/anime-fonts</dir>
      <dir>${pkgs.mpvScripts.uosc}/share/fonts</dir>
    </fontconfig>
  '';
}
