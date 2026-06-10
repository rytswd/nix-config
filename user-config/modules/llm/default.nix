# Linux entrypoint. ollama.nix uses `services.ollama` (systemd) + GPU
# packages and is Linux-only; Darwin imports ./macos.nix instead, which
# omits it. Platform is decided here by which file the profile imports, so
# no `pkgs`-gated `imports` (that would recurse during module discovery).
{ ... }:
{
  imports = [
    ./agents.nix
    ./extra-tools.nix
    ./skills.nix
    ./ollama.nix
  ];
}
