{ pkgs
, lib
, config
, ...}:

{
  options = {
    dictionary.hunspell.enable = lib.mkEnableOption "Enable Hunspell and its dictionaries.";
  };

  config = lib.mkIf config.dictionary.hunspell.enable {
    home.packages = [
      # https://github.com/hunspell/hunspell
      # NOTE: Hunspell setup takes a list argument.
      (pkgs.hunspellWithDicts [
        pkgs.hunspellDicts.en_GB-large
        pkgs.hunspellDicts.en_US-large
      ])
    ];
    # xdg.dataFile = {
    #   "hunspell/some_dict".source = some_file; # TODO: If I were to pull in like this, I need to sort this out.
    # };
  };
}
