{ lib, pkgs, source }:

let
  luajit' = pkgs.luajit.override { enable52Compat = true; };
in

pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "aegisub";
  version = source.version;
  src = pkgs.fetchFromGitHub {
    owner = source.owner;
    repo  = source.repo;
    rev   = source.rev;
    hash  = source.hash;
  };

  nativeBuildInputs = with pkgs; [
    meson
    intltool
    ninja
    pkg-config
    python3
    wrapGAppsHook3
    wxwidgets_3_3  # for wx-config
  ];

  buildInputs = with pkgs; [
    alsa-lib
    boost
    expat
    ffmpeg
    ffms
    fftw
    fontconfig
    freetype
    fribidi
    harfbuzz
    hunspell
    icu
    libGL
    libass
    libportal-gtk3
    libpulseaudio
    libuchardet
    luajit'
    openal
    portaudio
    wxwidgets_3_3
    zlib
  ];

  mesonFlags = [
    (lib.mesonEnable "alsa" true)
    (lib.mesonEnable "openal" true)
    (lib.mesonEnable "libpulse" true)
    (lib.mesonEnable "portaudio" true)
    (lib.mesonEnable "avisynth" false)
    (lib.mesonEnable "hunspell" true)
    (lib.mesonEnable "libportal" true)
    (lib.mesonBool "system_luajit" true)
    (lib.mesonBool "enable_update_checker" false)
    (lib.mesonBool "tests" false)
    "-Dwarning_level=1"
  ];

  hardeningDisable = [ "bindnow" "relro" ];

  strictDeps = true;

  postPatch = ''
    patchShebangs tools
  '';

  preBuild = ''
    cat > git_version.h <<EOF
    #define BUILD_GIT_VERSION_NUMBER 0
    #define BUILD_GIT_VERSION_STRING "${finalAttrs.version}"
    EOF
  '';

  meta = {
    description = "Advanced subtitle editor (arch1t3cht fork)";
    homepage = "https://github.com/arch1t3cht/Aegisub";
    license = lib.licenses.bsd3;
    mainProgram = "aegisub";
    platforms = lib.platforms.unix;
  };
})
