{ lib, pkgs, source }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "mikan";
  version = source.version;
  src = pkgs.fetchurl {
    url = source.url;
    hash = source.hash;
  };

  nativeBuildInputs = with pkgs; [
    unzip
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = with pkgs; [
    glib
    gtk3
    libepoxy
    at-spi2-atk
    cairo
    pango
    gdk-pixbuf
    libx11
    libxcursor
    libxext
    libxrandr
    libxi
  ];

  desktopItems = [
    (pkgs.makeDesktopItem {
      name = "io.nichijou.flutter.mikan";
      desktopName = "Mikan";
      comment = "Mikan Project";
      exec = "mikan %U";
      terminal = false;
      icon = "mikan";
      startupNotify = true;
      startupWMClass = "mikan";
      categories = [ "Network" "AudioVideo" ];
      type = "Application";
    })
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/mikan $out/bin

    cp -r mikan   $out/opt/mikan/
    cp -r lib     $out/opt/mikan/
    cp -r data    $out/opt/mikan/
    chmod +x $out/opt/mikan/mikan

    install -Dm444 \
      $out/opt/mikan/data/flutter_assets/assets/mikan.png \
      $out/share/icons/hicolor/512x512/apps/mikan.png

    runHook postInstall
  '';

  preFixup = ''
    addAutoPatchelfSearchPath $out/opt/mikan/lib
  '';

  autoPatchelfIgnoreMissingDeps = [ "libjvm.so" ];

  postFixup = ''
    makeWrapper $out/opt/mikan/mikan $out/bin/mikan \
      --chdir $out/opt/mikan \
      --prefix LD_LIBRARY_PATH : $out/opt/mikan/lib
  '';

  meta = {
    description = "Mikan Project desktop client";
    homepage = "https://github.com/iota9star/mikan_flutter";
    license = lib.licenses.asl20;
    mainProgram = "mikan";
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
