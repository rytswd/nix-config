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
      pkgs.aspellWithDicts (dicts: with dicts; [
        pkgs.aspellDicts.en
        pkgs.aspellDicts.en-computers
        pkgs.aspellDicts.en-science
      ])
    ];
  };
}
