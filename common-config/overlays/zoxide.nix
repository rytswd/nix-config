# Ref: https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/misc/zoxide/default.nix

{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, withFzf ? true
, fzf
, installShellFiles
, libiconv
}:

# NOTE: This is a manual overlay setup.
#
# Version Update Steps:
#
# 1. Update version in `version`
# 2. Remove hash in `src.hash` and `cargoHash` (not remove the key, just the value)
# 3. Build and get the error message containing the hash
# 4. Fill the hash in `src.hash`
# 5. Build again and get the error message containing the hash
# 6. Fill the hash in `cargoHash`
#

rustPlatform.buildRustPackage rec {
  pname = "zoxide";
  version = "0.10.0-manual"; # Manually updated

  src = fetchFromGitHub {
    owner = "ajeetdsouza";
    repo = "zoxide";
    # rev = "v${version}";
    rev = "3022cf3686b85288e6fbecb2bd23ad113fd83f3b";
    sha256 = "";
  };

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = lib.optionals stdenv.isDarwin [ libiconv ];

  postPatch = lib.optionalString withFzf ''
    substituteInPlace src/util.rs \
      --replace '"fzf"' '"${fzf}/bin/fzf"'
  '';

  cargoSha256 = "sha256-uu7zi6prnfbi4EQ0+0QcTEo/t5CIwNEQgJkIgxSk5u4=";

  postInstall = ''
    installManPage man/man*/*
    installShellCompletion --cmd zoxide \
      --bash contrib/completions/zoxide.bash \
      --fish contrib/completions/zoxide.fish \
      --zsh contrib/completions/_zoxide
  '';

  meta = with lib; {
    description = "A fast cd command that learns your habits";
    homepage = "https://github.com/ajeetdsouza/zoxide";
    changelog = "https://github.com/ajeetdsouza/zoxide/raw/v${version}/CHANGELOG.md";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ ysndr cole-h SuperSandro2000 ];
    mainProgram = "zoxide";
  };
}
