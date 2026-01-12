{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./claude.nix
    ./gemini.nix
    ./opencode.nix
    ./pi.nix
  ];

  llm.claude.enable = lib.mkDefault true;
  llm.gemini.enable = lib.mkDefault true;
  llm.opencode.enable = lib.mkDefault true;
  llm.pi.enable = lib.mkDefault true;
}
