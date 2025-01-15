# Special thanks to:
# https://www.reddit.com/r/NixOS/comments/14dlvbr/sddm_theme/

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
  pname = "sddm-tokyo-night";
  version = "1.0.0"; # Any version information should do.
  src = fetchFromGitHub {
    owner = "rototrash";
    repo = "tokyo-night-sddm";
    rev = "320c8e74ade1e94f640708eee0b9a75a395697c6";
    sha256 = "sha256-JRVVzyefqR2L3UrEK2iWyhUKfPMUNUnfRZmwdz05wL0=";
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
    cp -aR $src $out/share/sddm/themes/tokyo-night
  '';
}
