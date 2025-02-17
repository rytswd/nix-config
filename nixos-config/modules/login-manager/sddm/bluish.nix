{ lib
, stdenvNoCC
, fetchFromGitHub
, wrapQtAppsHook
, qtbase
, qtsvg
, qtgraphicaleffects
, qtquickcontrols2
}:
stdenvNoCC.mkDerivation {
  pname = "sddm-bluish";
  version = "1.0.0"; # Any version information
  src = fetchFromGitHub {
    owner = "L4ki";
    repo = "Bluish-Plasma-Themes";
    rev = "0ff89cb290811c8113b5d91b8cdfa772df10f926";
    sha256 = "sha256-aJA5vPcrm3PVrWzw+hyKB5eH4wCU3EH+nWlElPjM9eo=";
  };
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
    cp -aR $src/Bluish\ SDDM\ Themes/Bluish-SDDM-6 $out/share/sddm/themes/bluish
  '';
}
