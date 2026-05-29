{ pkgs, inputs, ... }:
# LLM coding agents from the `llm-agents` flake. Trivial single-package
# entries are grouped here so each one isn't its own file.
let
  agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = [
    agents.claude-code
    agents.claudebox
    agents.codex
    # agents.code
    agents.gemini-cli
    agents.opencode
    agents.pi
  ];

  home.shellAliases = {
    # NOTE: Fetch is from extension.
    "pi-ro" = "pi --tools read,grep,find,ls,fetch";
    "pi-ns" = "pi --no-session";
  };
}
