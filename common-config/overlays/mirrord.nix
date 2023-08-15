{ pkgs }:

# NOTE: This is a manual overlay setup.
#
# Version Update Steps:
#
# 1. Update version in `rev`
# 2. Remove hash in `src.hash` and `cargoHash` (do not remove the key, just the value)
# 3. Build and get the error message containing the hash
# 4. Fill the hash in `src.hash`
# 5. Build again and get the error message containing the hash
# 6. Fill the hash in `cargoHash`
#

let lib = pkgs.lib;
    # rustPlatform = pkgs.rustPlatform;
    fenix = pkgs.fenix;
in
(pkgs.makeRustPlatform {
  inherit (fenix.toolchainOf {
    date = "2023-04-19";
    sha256 = "sha256-54rlXRNdMMf/KXvzoXPXHfAFZW4vGoYsd5yy8MKG+dI=";
  })
    cargo rustc rust-analyzer-nightly rust-src rustfmt;
}).buildRustPackage rec {
  pname = "mirrord-layer";
  version = "3.52.1";
  # version = "3.47.0";
  # version = "3.46.0";

  src = pkgs.fetchFromGitHub {
    owner = "metalbear-co";
    repo = "mirrord";
    rev = version;
    hash = "sha256-vK5Q5SDAdfnGGZH6Ikb+ot6lMNjzoiofwxbnXqO20/k=";
    # hash = "sha256-zf14Ubj5aHW9q42Kd8034MXqRiBT4DoEwDx2KW+45AQ=";
    # hash = "sha256-BE51k7BK/M5qQ1+0FcRD1VXk0wfPFiNQUtV6gHfN3pw="; # for 3.46.0
    postFetch = ''
      rm rust-toolchain.toml
    '';
  };

  cargoLock = {
    lockFile = ./mirrord.Cargo.lock;
    allowBuiltinFetchGit = true; # Bypass the outputHashes setup

    # outputHashes = {
    #   "finalfusion-0.14.0" = "17f4bsdzpcshwh74w5z119xjy2if6l2wgyjy56v621skr2r8y904";
    # };
  };

  buildInputs = [
    pkgs.protobuf
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    pkgs.darwin.apple_sdk.frameworks.Security
  ];
  # Needed for internal protobuf c wrapper library
  PROTOC = "${pkgs.protobuf}/bin/protoc";
  PROTOC_INCLUDE = "${pkgs.protobuf}/include";
  # Handle error E0554 about missing feature of `result_option_inspect`
  RUSTC_BOOTSTRAP = true;
  RUST_FLAGS = "--target=aarch64-apple-darwin";
  # MIRRORD_LAYER_FILE = "../../../target/universal-apple-darwin/debug/libmirrord_layer.dylib";

  meta = with lib; {
    description = "Mirrord for Kubernetes";
    homepage = "https://mirrord.dev";
    license = licenses.mit;
    maintainers = with maintainers; [ aviramha eyalb181 ];
    mainProgram = "mirrord";
  };
}
