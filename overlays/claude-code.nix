final: prev:
let
  # NOTE: For updating the version, run the following:
  #
  # nix run nixpkgs#nix-prefetch -- fetchzip --url "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-2.0.52.tgz"
  #
  # npm hash only changes when the dependency updates, and only found after built.
  claude-code-version = "2.0.52";
  claude-code-src-hash = "sha256-lYVuWP9ekI+xeUXNCXVqcq8OIzZwfdgBpk0PhSIStFs=";
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
