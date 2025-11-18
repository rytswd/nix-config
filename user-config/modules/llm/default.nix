{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./claude.nix
    ./gemini.nix
  ];

  llm.claude.enable = lib.mkDefault true;
  llm.gemini.enable = lib.mkDefault true;
}
