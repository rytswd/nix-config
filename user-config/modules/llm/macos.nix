# Darwin entrypoint: same LLM tooling as default.nix without ollama
# (Linux-only).
{ ... }:
{
  imports = [
    ./agents.nix
    ./extra-tools.nix
    ./skills.nix
  ];
}
