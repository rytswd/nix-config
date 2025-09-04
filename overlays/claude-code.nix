final: prev:
let
  # NOTE: For updating the version, run the following:
  #
  # nix shell nixpkgs#nix-prefetch
  # nix-prefetch fetchzip --url "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-1.0.88.tgz"
  # npm hash only changes when the dependency updates, and only found after built.
  claude-code-version = "1.0.88";
  claude-code-src-hash = "sha256-o0A9P0sBB2Fk18CArGGv/QBi55ZtFgoJ2/3gHlDwyEU=";
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
