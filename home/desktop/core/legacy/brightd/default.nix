{ lib, pkgs }:

pkgs.python3Packages.buildPythonApplication {
  pname = "brightd";
  version = "main";
  format = "other";

  src = ./brightd;
  dontUnpack = true;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/brightd
    patchShebangs $out/bin

    wrapProgram $out/bin/brightd \
      --prefix PATH : ${lib.makeBinPath [
        pkgs.brightnessctl
        pkgs.ddcutil
        pkgs.systemd
      ]}

    runHook postInstall
  '';

  meta = with lib; {
    mainProgram = "brightd";
    platforms = platforms.linux;
  };
}
