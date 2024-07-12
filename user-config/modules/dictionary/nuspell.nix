{ pkgs
, lib
, config
, ...}:

{
  options = {
    dictionary.nuspell.enable = lib.mkEnableOption "Enable Nuspell and its dictionaries.";
  };

  config = lib.mkIf config.dictionary.nuspell.enable {
    home.packages = [
      # https://github.com/nuspell/nuspell
      # NOTE: Nuspell uses the same dictionary as Hunspell.
      pkgs.nuspellWithDicts [
        pkgs.hunspellDicts.en_GB-large
        pkgs.hunspellDicts.en_US-large
      ];
    ];
  };
}
