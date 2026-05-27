{ pkgs, ... }:
{
  home.packages = [
    # http://aspell.net/
    # NOTE: GNU Aspell setup takes a function argument.
    (pkgs.aspellWithDicts (dicts: with dicts; [
      pkgs.aspellDicts.en
      pkgs.aspellDicts.en-computers
      pkgs.aspellDicts.en-science
    ]))
  ];
}
