{ pkgs, lib, ... }:
{
  imports = [
    ./agents.nix
    ./extra-tools.nix
    ./skills.nix
  ]
  # ollama.nix uses `services.ollama` (systemd) + GPU packages and is
  # Linux-only. Gate it so the rest of the module (pi, claude-code, codex,
  # ...) can be imported on macOS too.
  ++ lib.optional pkgs.stdenv.isLinux ./ollama.nix;
}
