final: prev:

{
  python-grip = prev.python311.pkgs.grip.overrideAttrs (old: rec {
    version = "4.6.2-latest"; # Created for my own use case

    src = prev.fetchFromGitHub {
      owner = "joeyespo";
      repo = "grip";
      rev = "a3f0ab5c8942ac15cf68f790b80c0a43b3a4c71e";
      hash = "sha256-ZOkuzGXgNJw9tj7/MATBojEmDszK7FcYyYKy59Qo19I=";
    };

    patches = [];

    # patches = [
    #   # https://github.com/NixOS/nixpkgs/issues/288478
    #   (fetchpatch {
    #     name = "set-default-encoding.patch";
    #     url = "https://github.com/joeyespo/grip/commit/2784eb2c1515f1cdb1554d049d48b3bff0f42085.patch";
    #     hash = "sha256-veVJKJtt8mP1jmseRD7pNR3JgIxX1alYHyQok/rBpiQ=";
    #   })
    #   # Patch with theme handling
    #   (fetchpatch {
    #     name = "set-default-encoding.patch";
    #     url = "https://github.com/joeyespo/grip/commit/a3f0ab5c8942ac15cf68f790b80c0a43b3a4c71e.patch";
    #     hash = "sha256-ZOkuzGXgNJw9tj7/MATBojEmDszK7FcYyYKy59Qo19I=";
    #   })
    # ];

  });
}
