{ pkgs, ... }:

let
  # NOTE: For using some overlay
  # emacs-overlay = import (fetchTarball {
  #     url = "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
  #     sha256 = "1jppksrfvbk5ypiqdz4cddxdl8z6zyzdb2srq8fcffr327ld5jj2";
  #   });
  # nixpkgs-with-emacs = import (builtins.fetchTarball {
  #   url = "https://github.com/NixOS/nixpkgs/archive/5f98e7c92b1a7030324c85c40fa0b46e0ba4cb23.tar.gz";
  #   sha256 = "sha256:1i2f7hfw5xp3hhkaaq8z6z9bhdx5yf2j65pmg4f1wxv4d0dswfpi";
  # }) {};

  # NOTE: This macport installation fails with clang-wrapper / compiler-rt dependencies.
  # emacs = pkgs.emacs29-macport.override {
  emacs = pkgs.emacs29.override {
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
  # package = emacs-with-packages;
  package = emacs;
  extraPackages = (epkgs: with epkgs; [
    vterm
    multi-vterm
    jinx
  ]);
}
