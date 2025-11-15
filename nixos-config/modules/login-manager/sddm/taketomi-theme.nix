{ lib
, stdenvNoCC
, wrapQtAppsHook
, qtbase
, qtsvg
, qtdeclarative
, qt5compat
}:
stdenvNoCC.mkDerivation {
  pname = "sddm-taketomi-theme";
  version = "1.0.0";

  src = ./taketomi-theme;

  dontBuild = true;

  nativeBuildInputs = [
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtsvg
    qtdeclarative
    qt5compat
  ];

  propagatedUserEnvPkgs = [
    qtbase
    qtsvg
    qtdeclarative
    qt5compat
  ];

  installPhase = ''
    mkdir -p $out/share/sddm/themes
    cp -aR $src $out/share/sddm/themes/taketomi-theme
  '';
}
