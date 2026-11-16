{ lib, pkgs, source }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "clice";
  version = lib.removePrefix "v" source.version;
  src = pkgs.fetchurl {
    url = source.url;
    hash = source.hash;
  };

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = [ pkgs.glibc ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r bin lib $out/

    runHook postInstall
  '';

  meta = {
    description = "C/C++ language server with template-aware navigation and C++20 modules";
    homepage = "https://github.com/clice-io/clice";
    license = lib.licenses.asl20;
    mainProgram = "clice";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
