{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./claude.nix
  ];

  llm.claude.enable = lib.mkDefault true;
}
