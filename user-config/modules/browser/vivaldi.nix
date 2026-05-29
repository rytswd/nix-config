{ pkgs, ... }:
{
  home.packages = [
    (pkgs.vivaldi.override {
      proprietaryCodecs = true;
      enableWidevine    = true;
    })
  ];
}
