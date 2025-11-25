final: prev:
let
  # NOTE: For updating the version, run the following:
  #
  #     nix-prefetch-github google-gemini gemini-cli --rev "v0.17.1"
  #
  # The latest release can be found here:
  # https://github.com/google-gemini/gemini-cli/releases
  gemini-cli-version = "v0.17.1";
  gemini-cli-src-hash = "sha256-zfORrAMVozHiUawWiy3TMT+pjEaRJ/DrHeDFPJiCp38=";

  # npm hash only changes when the dependency updates, and only found after built.
  # I can get the hash by providing `lib.fakeHash`.
  # gemini-cli-npmDepsHash = prev.lib.fakeHash;
  gemini-cli-npmDepsHash = "sha256-dKaKRuHzvNJgi8LP4kKsb68O5k2MTqblQ+7cjYqLqs0=";
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
