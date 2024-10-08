{ pkgs
, lib
, config
, ...}:

{
  options = {
    dictionary.enchant.enable = lib.mkEnableOption "Enable Enchant.";
  };

  # Some note for Enchant setup for Emacs Jinx
  # Ref: https://www.reddit.com/r/emacs/comments/1eg9hdg/multilingual_spellchecking_omg_what_a_rabbit_hole/

  config = lib.mkIf config.dictionary.enchant.enable {
    home.packages = [
      pkgs.enchant  # https://github.com/AbiWord/enchant
    ];
    xdg.configFile = {
      # Enchant config
      # NOTE: There seems to be no other way to configure the extra dictionaries
      # for enchant. This setup is rather verbose but this works correctly, and
      # thus will keep it like this for now.
      "enchant/enchant.ordering".source = ./enchant/enchant.ordering;
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
