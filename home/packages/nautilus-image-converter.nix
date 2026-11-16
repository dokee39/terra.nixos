{ lib, pkgs, src }:

pkgs.stdenv.mkDerivation {
  pname = "nautilus-image-converter";
  version = "unstable";

  inherit src;

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
    gettext
  ];

  buildInputs = with pkgs; [
    glib
    gtk4
    nautilus.dev
    imagemagick
  ];

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "nautilus_extension_dir = libnautilus_extension.get_pkgconfig_variable('extensiondir')" \
                     "nautilus_extension_dir = get_option('libdir') / 'nautilus/extensions-4'"

    substituteInPlace po/fr.po \
      --replace-fail 'Content-Type: text/plain; charset=' 'Content-Type: text/plain; charset=UTF-8' \
      --replace-fail 'Content-Transfer-Encoding: ' 'Content-Transfer-Encoding: 8bit'

    substituteInPlace src/nautilus-image-resizer.c \
      --replace-fail /usr/bin/convert ${pkgs.imagemagick}/bin/convert
    substituteInPlace src/nautilus-image-rotator.c \
      --replace-fail /usr/bin/convert ${pkgs.imagemagick}/bin/convert
  '';

  meta = {
    description = "Nautilus extension to resize and rotate images";
    homepage = "https://gitlab.gnome.org/coreyberla/nautilus-image-converter";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
