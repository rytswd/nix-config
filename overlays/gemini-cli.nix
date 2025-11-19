final: prev:
let
  # NOTE: For updating the version, run the following:
  #
  #     nix-prefetch-github -- google-gemini gemini-cli --rev "0.17.0-preview.0"
  gemini-cli-version = "0.17.0-preview.0";
  gemini-cli-src-hash = "sha256-zkFRkadkjQcdOBLHTV/+LKengcrjt0AkA1Va2rS1exU=";
  # npm hash only changes when the dependency updates, and only found after built.
  # I can get the hash by providing `lib.fakeHash`.
  # gemini-cli-npmDepsHash = prev.lib.fakeHash;
  gemini-cli-npmDepsHash = "sha256-yDCUZD//nM6Xr8CU86nv+ug5BrqRGdnVixU8mGpVies=";
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
