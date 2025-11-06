{ lib
, stdenvNoCC
, wrapQtAppsHook
, qtbase
, qtsvg
, qtgraphicaleffects
, qtquickcontrols2
}:
stdenvNoCC.mkDerivation {
  pname = "sddm-taketomi-theme";
  version = "1.0.0";

  src = ./taketomi-theme;

  dontBuild = true;

  nativeBuildInputs = [
    wrapQtAppsHook
  ];

  propagatedUserEnvPkgs = [
    qtbase
    qtsvg
    qtgraphicaleffects
    qtquickcontrols2
  ];

  installPhase = ''
    mkdir -p $out/share/sddm/themes
    cp -aR $src $out/share/sddm/themes/taketomi-theme
  '';
}
