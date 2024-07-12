{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./enchant.nix
    ./aspell.nix
    ./hunspell.nix
    ./nuspell.nix
  ];

  dictionary.enchant.enable = lib.mkDefault true;
  dictionary.aspell.enable = lib.mkDefault true;
  dictionary.hunspell.enable = lib.mkDefault true;
  dictionary.nuspell.enable = lib.mkDefault true;
}
