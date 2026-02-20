{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./claude.nix
    ./codex.nix
    ./gemini.nix
    ./opencode.nix
    ./pi.nix
    ./extra-tools.nix
  ];

  llm.claude.enable = lib.mkDefault true;
  # llm.codex.enable = lib.mkDefault true;
  llm.gemini.enable = lib.mkDefault true;
  llm.opencode.enable = lib.mkDefault true;
  llm.pi.enable = lib.mkDefault true;
  llm.extra-tools.enable = lib.mkDefault true;
}
