{
  rustPlatform,
  fetchFromGitHub,
  lib,

  installShellFiles,
  stdenv,
  pkg-config,
  clang,
  cmake,
  cargo-about,
  frida-tools,
}:

# NOTE: This is not used. The current upstream uses a binary version rather
# than building one from source, so this may be something I want to do in the
# future instead.

# TODO: This is not building due to the frida dependency. The actual build by
# Cargo relies on downloading the target frida binary from GitHub directly,
# and that won't work with Nix build. This has to be added as the build
# dependency somehow.
let
  ver = "3.128.0";
in rustPlatform.buildRustPackage rec {
  pname = "mirrord";
  version = ver;

  # buildFeatures = [ "const_trait_impl" "io_error_more" ];

  src = fetchFromGitHub {
    owner = "metalbear-co";
    repo = "mirrord";
    rev = ver;
    hash = "sha256-3rcZwhAeRnz4MM7IfDkTW6EEZepOEziKbwf9rrx3LJY=";
  };

  cargoHash = "";

  # requires nightly features (feature(portable_simd))
  RUSTC_BOOTSTRAP = true;

  cargoLock = {
    # lockFile = "${src}/Cargo.lock";
    lockFile = ./Cargo.lock;
    outputHashes = {
      "apple-codesign-0.27.0" = "sha256-kAeO0UkBLsfkfiRzdCxCyHRwFdoTtHFWa9/tY2+lX2U=";
      "bs-filter-0.1.0" = "sha256-IxuilE2MGdM/1lfvqJ1k5blE036IZEXam6VMgZBHZsQ=";
      "iptables-0.5.1" = "sha256-W0EqU6TFx0eWKAtM9sZeWtgR0r49SGbckOFdjsF6+Ew=";
      "kube-0.96.0" = "sha256-Ly4vbxjltwSAOAd8qW/CVXF/LhSNMakYQSg4htSqm1c=";
    };
  };

  nativeBuildInputs = [
    frida-tools
    installShellFiles
    pkg-config
    clang
    cmake
    rustPlatform.bindgenHook
    cargo-about
  ];

  meta = {
    description = "Mirrord for Kubernetes";
    homepage = "https://mirrord.dev";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rytswd ];
    mainProgram = "mirrord";
  };
}
