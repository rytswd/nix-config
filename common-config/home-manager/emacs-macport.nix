{ pkgs, ... }:

let
  emacs-macport = pkgs.emacs29-macport.override {
    withNativeCompilation = true;
    withSQLite3 = true;
    withTreeSitter = true;
    withWebP = true;
  };

  # NOTE: This was something mentioned in Reddit, but I took a simpler
  # home-manager setting below.
  # emacs-with-packages = (pkgs.emacsPackagesFor emacs).emacsWithPackages (epkgs: with epkgs; [
  #   vterm
  #   multi-vterm
  #   jinx    # https://github.com/minad/jinx
  # ]);
in
{
  enable = true;

  package = emacs-macport;

  extraPackages = (epkgs: with epkgs; [
    vterm
    jinx
    # treesit-grammars.with-all-grammars
    treesit-grammars-custom.with-all-grammars
  ]);
}
