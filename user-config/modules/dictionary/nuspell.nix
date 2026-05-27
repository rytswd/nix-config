{ pkgs, ... }:
{
  home.packages = [
    # https://github.com/nuspell/nuspell
    # NOTE: Nuspell uses the same dictionary as Hunspell.
    (pkgs.nuspell.withDicts (_: [
      pkgs.hunspellDicts.en_GB-large
      pkgs.hunspellDicts.en_US-large
    ]))
  ];
}
