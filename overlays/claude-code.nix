final: prev:
let
  # NOTE: For updating the version, run the following:
  #
  # nix shell nixpkgs#nix-prefetch
  # nix-prefetch fetchzip --url "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-2.0.14.tgz"
  # npm hash only changes when the dependency updates, and only found after built.
  claude-code-version = "2.0.14";
  claude-code-src-hash = "sha256-U/wd00eva/qbSS4LpW1L7nmPW4dT9naffeMkHQ5xr5o=";
  claude-code-npmDepsHash = "sha256-LkQf2lW6TM1zRr10H7JgtnE+dy0CE7WCxF4GhTd4GT4=";
in
{
  claude-code = prev.claude-code.overrideAttrs (old: rec {
    version = claude-code-version;
    src = prev.fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${claude-code-version}.tgz";
      hash = claude-code-src-hash;
    };
    npmDepsHash = claude-code-npmDepsHash;
  });
}
