final: prev:
let
  claude-code-version = "1.0.72";
  claude-code-src-hash = "sha256-1vIElqZ5sk62o1amdfOqhmSG4B5wzKWDLcCgvQO4a5o=";
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
