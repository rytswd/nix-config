{ pkgs
, lib
, config
, ...}:

{
  options = {
    dictionary.aspell.enable = lib.mkEnableOption "Enable Aspell and its dictionaries.";
  };

  config = lib.mkIf config.dictionary.aspell.enable {
    home.packages = [
      # http://aspell.net/
      # NOTE: GNU Aspell setup takes a function argument.
      (with pkgs; aspellWithDicts (dicts: with dicts; [
        aspellDicts.en
        aspellDicts.en-computers
        aspellDicts.en-science
      ]))
    ];
  };
}
