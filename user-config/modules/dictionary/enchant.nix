{ pkgs
, lib
, config
, ...}:

{
  options = {
    dictionary.enchant2.enable = lib.mkEnableOption "Enable Enchant.";
  };

  config = lib.mkIf config.dictionary.enchant2.enable {
    home.packages = [
      pkgs.enchant  # https://github.com/AbiWord/enchant
    ];
    xdg.configFile = {
      # Enchant config
      "enchant/enchant.ordering".source = ../../../common-config/enchant/enchant.ordering;
      "enchant/hunspell/en_US.aff".source = "${pkgs.hunspellDicts.en_US-large}/share/hunspell/en_US.aff";
      "enchant/hunspell/en_US.dic".source = "${pkgs.hunspellDicts.en_US-large}/share/hunspell/en_US.dic";
      "enchant/hunspell/en_GB.aff".source = "${pkgs.hunspellDicts.en_GB-large}/share/hunspell/en_GB.aff";
      "enchant/hunspell/en_GB.dic".source = "${pkgs.hunspellDicts.en_GB-large}/share/hunspell/en_GB.dic";
      "enchant/aspell/en-computers.rws".source = "${pkgs.aspellDicts.en-computers}/lib/aspell/en-computers.rws";
      "enchant/aspell/en_US-science.rws".source = "${pkgs.aspellDicts.en-science}/lib/aspell/en_US-science.rws";
      "enchant/aspell/en_GB-science.rws".source = "${pkgs.aspellDicts.en-science}/lib/aspell/en_GB-science.rws";

    };
  };
}
