final: prev:
let
  # NOTE: For updating the version, run the following:
  #
  #     nix-prefetch-github google-gemini gemini-cli --rev "v0.18.4"
  #
  # The latest release can be found here:
  # https://github.com/google-gemini/gemini-cli/releases
  gemini-cli-version = "v0.18.4";
  gemini-cli-src-hash = "sha256-TSHL3X+p74yFGTNFk9r4r+nnul2etgVdXxy8x9BjsRg=";

  # npm hash only changes when the dependency updates, and only found after built.
  # I can get the hash by providing `lib.fakeHash`.
  # gemini-cli-npmDepsHash = prev.lib.fakeHash;
  gemini-cli-npmDepsHash = "sha256-2Z6YrmUHlYKRU3pR0ZGwQbBgzNFqakBB6LYZqf66nSs=";
in
{
  gemini-cli = prev.gemini-cli.overrideAttrs (old: rec {
    version = gemini-cli-version;
    src = prev.fetchFromGitHub {
      owner = "google-gemini";
      repo = "gemini-cli";
      # Currently there's no release tag
      rev = gemini-cli-version;
      hash = gemini-cli-src-hash;
    };
    npmDeps = prev.fetchNpmDeps {
      inherit src;
      hash = gemini-cli-npmDepsHash;
    };
  });
}
